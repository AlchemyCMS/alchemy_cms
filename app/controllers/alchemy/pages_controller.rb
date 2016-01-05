module Alchemy
  class PagesController < Alchemy::BaseController
    include OnPageLayout::CallbacksRunner

    # Redirects to signup path, if no admin user is present yet
    before_action if: :signup_required? do
      redirect_to Alchemy.signup_path
    end

    # Redirecting concerns. Order is important here!
    include SiteRedirects
    include LocaleRedirects

    before_action :load_index_page, only: [:index]
    before_action :load_page, only: [:show]

    # Page redirects need to run after the page was loaded. Order is important here!
    include LegacyPageRedirects
    include PageRedirects

    # We only need to set the +@root_page+ if we are sure that no more redirects happen.
    before_action :set_root_page, only: [:index, :show]

    # Page layout callbacks need to run after all other callbacks
    before_action :run_on_page_layout_callbacks,
      if: :run_on_page_layout_callbacks?,
      only: [:index, :show]

    rescue_from ActionController::UnknownFormat, with: :page_not_found!

    # == The index action gets invoked if one requests '/' or '/:locale'
    #
    # If the locale is the default locale, then it redirects to '/' without the locale.
    #
    # Loads the current language root page. The current language is either loaded via :locale
    # parameter or, if that's missing, the default language is used.
    #
    # If this page is not published then it loads the first published descendant it finds.
    #
    # If no public page can be found it renders a 404 error.
    #
    # If the configuration is set to :redirect_index, then the request gets redirected
    # to that page, instead of displaying it.
    #
    def index
      @page || page_not_found!

      if Alchemy::Config.get(:redirect_index)
        redirect_permanently_to page_redirect_url
      else
        authorize! :index, @page
        render_page if render_fresh_page?
      end
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
      if redirect_url.present?
        redirect_permanently_to redirect_url
      else
        authorize! :show, @page
        render_page if render_fresh_page?
      end
    end

    # Renders a search engine compatible xml sitemap.
    def sitemap
      @pages = Page.sitemap
      respond_to do |format|
        format.xml { render layout: 'alchemy/sitemap' }
      end
    end

    private

    # == Loads index page
    #
    # Loads the current public language root page.
    #
    # If the root page is not public it loads the first published child.
    # This can be configured via `redirect_to_public_child` [default: true]
    #
    def load_index_page
      @page ||= public_root_page || first_public_child
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
      @page ||= Page.contentpages.find_by(
        urlname: params[:urlname],
        language_code: params[:locale] || Language.current.code
      )
    end

    # Returns the current language root page, if it's published.
    #
    # Otherwise it returns nil.
    #
    def public_root_page
      @root_page ||= Language.current_root_page
      @root_page if @root_page.public?
    end

    # Returns the first public child of the current language root page.
    #
    # If +redirect_to_public_child+ is configured to +false+ it returns +nil+.
    #
    def first_public_child
      if Alchemy::Config.get(:redirect_to_public_child)
        @root_page.descendants.published.first
      end
    end

    # Redirects to given url with 301 status
    def redirect_permanently_to(url)
      redirect_to url, status: :moved_permanently
    end

    # Returns url parameters that are not internal show page params.
    #
    # * action
    # * controller
    # * urlname
    # * locale
    #
    def additional_params
      params.symbolize_keys.delete_if do |key, _|
        [:action, :controller, :urlname, :locale].include?(key)
      end
    end

    # == Renders the page :show template
    #
    # Handles html and rss requests (for pages containing a feed)
    #
    # Omits the layout, if the request is a XHR request.
    #
    def render_page
      respond_to do |format|
        format.html do
          render action: :show, layout: !request.xhr?
        end

        format.rss do
          if @page.contains_feed?
            render action: :show, layout: false, handlers: [:builder]
          else
            render xml: {error: 'Not found'}, status: 404
          end
        end
      end
    end

    def set_root_page
      @root_page ||= Language.current_root_page
    end

    def signup_required?
      if Alchemy.user_class.respond_to?(:admins)
        Alchemy.user_class.admins.size == 0 && @page.nil?
      end
    end

    # Returns true if the page cache control headers should be set.
    #
    # == Disable Alchemy's page caching globally
    #
    #     # config/alchemy/config.yml
    #     ...
    #     cache_pages: false
    #
    # == Disable caching on page layout level
    #
    #     # config/alchemy/page_layouts.yml
    #     - name: contact
    #       cache: false
    #
    # == Note:
    #
    # This only sets the cache control headers and skips rendering of the page body,
    # if the cache is fresh.
    # This does not disable the fragment caching in the views.
    # So if you don't want a page and it's elements to be cached,
    # then be sure to not use <% cache element %> in the views.
    #
    # @returns Boolean
    #
    def cache_page?
      return false if @page.nil? ||
        !Rails.application.config.action_controller.perform_caching ||
        !Alchemy::Config.get(:cache_pages)
      page_layout = PageLayout.get(@page.page_layout)
      page_layout['cache'] != false && page_layout['searchresults'] != true
    end

    # Returns the etag used for response headers.
    #
    # If a user is logged in, we append theirs etag to prevent caching of user related content.
    #
    # IMPORTANT:
    #
    # If your user does not have a +cache_key+ method (i.e. it's not an ActiveRecord model),
    # you have to ensure to implement it and return a unique identifier for that particular user.
    # Otherwise all users will see the same cached page, regardless of user's state.
    #
    def page_etag
      @page.cache_key + current_alchemy_user.try(:cache_key).to_s
    end

    # We only render the page if either the cache is disabled for this page
    # or the cache is stale, because it's been republished by the user.
    #
    def render_fresh_page?
      !cache_page? || stale?(etag: page_etag,
        last_modified: @page.published_at,
        public: !@page.restricted)
    end

    def page_not_found!
      not_found_error!("Alchemy::Page not found \"#{request.fullpath}\"")
    end
  end
end
