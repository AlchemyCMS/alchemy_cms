# frozen_string_literal: true

module Alchemy
  class PagesController < Alchemy::BaseController
    SHOW_PAGE_PARAMS_KEYS = [
      "action",
      "controller",
      "urlname",
      "locale"
    ]

    include OnPageLayout::CallbacksRunner

    # Redirecting concerns. Order is important here!
    include SiteRedirects

    before_action :enforce_no_locale,
      if: :locale_prefix_not_allowed?,
      only: [:index, :show]

    before_action :load_index_page, only: [:index]
    before_action :load_page, only: [:show]

    # Legacy page redirects need to run after the page was loaded and before we render 404.
    include LegacyPageRedirects

    # From here on, we need a published +@page+ to work with!
    before_action :page_not_found!, unless: -> { @page&.public? }, only: [:index, :show]

    # Page redirects need to run after the page was loaded and we're sure to have a public +@page+ set.
    before_action :enforce_locale,
      if: :locale_prefix_missing?,
      only: [:index, :show]

    # Page layout callbacks need to run after all other callbacks
    before_action :run_on_page_layout_callbacks,
      if: :run_on_page_layout_callbacks?,
      only: [:index, :show]

    before_action :set_expiration_headers, only: [:index, :show], if: -> { @page }

    rescue_from ActionController::UnknownFormat, with: :page_not_found!

    # == The index action gets invoked if one requests '/' or '/:locale'
    #
    # If the locale is the default locale, then it redirects to '/' without the locale.
    #
    # Loads the current language root page. The current language is either loaded via :locale
    # parameter or, if that's missing, the default language is used.
    #
    # If this page is not published then it redirects to the first published descendant it finds.
    #
    # If no public page can be found it renders a 404 error.
    #
    def index
      show
    end

    # == The show action gets invoked if one requests '/:urlname' or '/:locale/:urlname'
    #
    # If the locale is the default locale, then it redirects to '/' without the locale.
    #
    # Loads the page via it's urlname. If more than one language is published the
    # current language is either loaded via :locale parameter or, if that's missing,
    # the page language is used and a redirect to the page with prefixed locale happens.
    #
    # If the requested page is not published then it redirects to the first published
    # descendant it finds. If no public page can be found it renders a 404 error.
    #
    def show
      authorize! :show, @page
      render_page if render_fresh_page?
    end

    # Renders a search engine compatible xml sitemap.
    def sitemap
      @pages = Page.sitemap
      respond_to do |format|
        format.xml { render layout: "alchemy/sitemap" }
      end
    end

    private

    # Redirects to requested action without locale prefixed
    def enforce_no_locale
      redirect_permanently_to additional_params.merge(locale: nil)
    end

    # Is the requested locale allowed?
    #
    # If Alchemy is not in multi language mode or the requested locale is the default locale,
    # then we want to redirect to a non prefixed url.
    #
    def locale_prefix_not_allowed?
      params[:locale].present? && !multi_language? ||
        params[:locale].presence == ::I18n.default_locale.to_s
    end

    # == Loads index page
    #
    # Loads the current public language root page.
    #
    # If no index page and no admin users are present we show the "Welcome to Alchemy" page.
    #
    def load_index_page
      @page ||= Language.current_root_page
      Current.page = @page

      if signup_required? && @page.nil?
        render template: "alchemy/welcome", layout: false
      elsif !@page&.public?
        render template: "alchemy/no_index", layout: false
      end
    end

    # == Loads page by urlname
    #
    # If a locale is specified in the request parameters,
    # scope pages to it to make sure we can raise a 404 if the urlname
    # is not available in that language.
    #
    # @return Alchemy::Page
    # @return NilClass
    #
    def load_page
      page_not_found! unless Current.language

      @page ||= Current.language.pages.contentpages.find_by(
        urlname: params[:urlname],
        language_code: params[:locale] || Current.language.code
      )
      Current.page = @page
    end

    def enforce_locale
      redirect_permanently_to page_locale_redirect_url(locale: Current.language.code)
    end

    def locale_prefix_missing?
      multi_language? && params[:locale].blank? && !default_locale?
    end

    def default_locale?
      Current.language.code.to_sym == ::I18n.default_locale.to_sym
    end

    # Page url with or without locale while keeping all additional params
    def page_locale_redirect_url(options = {})
      options = {
        locale: prefix_locale? ? @page.language_code : nil,
        urlname: @page.urlname
      }.merge(options)

      alchemy.show_page_path additional_params.merge(options)
    end

    # Redirects to given url with 301 status
    def redirect_permanently_to(url)
      redirect_to url, status: 301
    end

    # Returns url parameters that are not internal show page params.
    #
    # * action
    # * controller
    # * urlname
    # * locale
    #
    def additional_params
      params.to_unsafe_hash.delete_if do |key, _|
        SHOW_PAGE_PARAMS_KEYS.include?(key)
      end
    end

    # == Renders the page :show template
    #
    # Handles html requests
    #
    # Omits the layout, if the request is a XHR request.
    #
    def render_page
      respond_to do |format|
        format.html do
          render action: :show, layout: !request.xhr?
        end
      end
    end

    def set_expiration_headers
      if must_not_cache?
        expires_now
      else
        expires_in @page.expiration_time, {public: !@page.restricted}.merge(caching_options)
      end
    end

    def caching_options
      if Alchemy.config.page_cache.stale_while_revalidate
        {
          stale_while_revalidate: Alchemy.config.page_cache.stale_while_revalidate
        }
      else
        {
          must_revalidate: true
        }
      end
    end

    def signup_required?
      if Alchemy.user_class.respond_to?(:admins)
        Alchemy.user_class.admins.empty?
      end
    end

    # Returns the etag used for response headers.
    #
    # The etag is composed of:
    # - The page's cache key (includes updated_at timestamp)
    # - Published element IDs (changes when elements enter/leave the published scope)
    # - The current user's cache key (for user-specific content)
    #
    # This ensures HTTP caches invalidate when scheduled elements become visible
    # or hidden, even though the page's updated_at hasn't changed.
    #
    # IMPORTANT:
    #
    # If your user does not have a +cache_key_with_version+ method (i.e. it's not an ActiveRecord model),
    # you have to ensure to implement it and return a unique identifier for that particular user.
    # Otherwise all users will see the same cached page, regardless of user's state.
    #
    def page_etag
      elements_cache_key = @page.public_version&.elements&.published&.order(:id)&.pluck(:id)
      [@page, elements_cache_key, current_alchemy_user]
    end

    # We only render the page if either the cache is disabled for this page
    # or the cache is stale, because it's been republished by the user.
    #
    def render_fresh_page?
      must_not_cache? || stale?(
        etag: page_etag,
        public: !@page.restricted,
        template: "pages/show"
      )
    end

    # don't cache pages if we have flash message to display or the page has caching disabled
    def must_not_cache?
      !caching_enabled? || !@page.cache_page? || flash.present?
    end

    def caching_enabled?
      Rails.application.config.action_controller.perform_caching &&
        Alchemy.config.cache_pages
    end

    def page_not_found!
      not_found_error!("Alchemy::Page not found \"#{request.fullpath}\"")
    end
  end
end
