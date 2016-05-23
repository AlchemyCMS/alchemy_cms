module Alchemy
  class PagesController < Alchemy::BaseController
    include OnPageLayout::CallbacksRunner

    # Redirecting concerns. Order is important here!
    include SiteRedirects
    include LocaleRedirects

    before_action :load_index_page, only: [:index]
    before_action :load_page, only: [:show]

    # Legacy page redirects need to run after the page was loaded and before we render 404.
    include LegacyPageRedirects

    # From here on, we need a +@page+ to work with!
    before_action :page_not_found!, if: -> { @page.blank? }, only: [:index, :show]

    # Page redirects need to run after the page was loaded and we're sure to have a +@page+ set.
    include PageRedirects

    # We only need to set the +@root_page+ if we are sure that no more redirects happen.
    before_action :set_root_page, only: [:index, :show]

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
    # If this page is not published then it loads the first published descendant it finds.
    #
    # If no public page can be found it renders a 404 error.
    #
    def index
      if Alchemy::Config.get(:redirect_index)
        ActiveSupport::Deprecation.warn("The configuration option `redirect_index` is deprecated and will be removed with the release of Alchemy v4.0")
        raise "Remove deprecated `redirect_index` configuration!" if Alchemy.version == "4.0.0.rc1"
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
    # This can be configured via +redirect_to_public_child+ [default: true]
    #
    # If no index page and no admin users are present we show the "Welcome to Alchemy" page.
    #
    def load_index_page
      @page ||= public_root_page || first_public_child
      render template: 'alchemy/welcome', layout: false if signup_required?
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
      @page ||= Language.current.pages.contentpages.find_by(
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
      @root_page if @root_page && @root_page.public?
    end

    # Returns the first public child of the current language root page.
    #
    # If +redirect_to_public_child+ is configured to +false+ it returns +nil+.
    #
    def first_public_child
      if Alchemy::Config.get(:redirect_to_public_child)
        return unless @root_page
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

    def set_expiration_headers
      if @page.cache_page?
        expires_in @page.expiration_time, public: !@page.restricted
      else
        expires_now
      end
    end

    def set_root_page
      @root_page ||= Language.current_root_page
    end

    def signup_required?
      if Alchemy.user_class.respond_to?(:admins)
        Alchemy.user_class.admins.empty? && @page.nil?
      end
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
      !@page.cache_page? || stale?(etag: page_etag,
        last_modified: @page.published_at,
        public: !@page.restricted,
        template: 'pages/show')
    end

    def page_not_found!
      not_found_error!("Alchemy::Page not found \"#{request.fullpath}\"")
    end
  end
end
