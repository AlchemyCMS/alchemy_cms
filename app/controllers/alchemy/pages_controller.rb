module Alchemy
  class PagesController < Alchemy::BaseController
    # We need to include this helper because we need the breadcrumb method.
    # And we cannot define the breadcrump method as helper_method, because rspec does not see helper_methods.
    # Not the best solution, but's working.
    # Anyone with a better idea please provide a patch.
    include BaseHelper

    rescue_from ActionController::RoutingError, :with => :render_404

    before_filter :enforce_primary_host_for_site
    before_filter :render_page_or_redirect, :only => [:show]
    before_filter :load_page
    authorize_resource only: 'show'

    # Showing page from params[:urlname]
    # @page is fetched via before filter
    # @root_page is fetched via before filter
    # @language fetched via before_filter in alchemy_controller
    # querying for search results if any query is present via before_filter
    def show
      expires_in cache_page? ? 1.month : 0
      if !cache_page? || stale?(etag: @page, last_modified: @page.published_at, public: !@page.restricted)
        respond_to do |format|
          format.html { render layout: !request.xhr? }
          format.rss do
            if @page.contains_feed?
              render action: 'show', layout: false, handlers: [:builder]
            else
              render xml: {error: 'Not found'}, status: 404
            end
          end
          format.json { render json: @page }
        end
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

    # Load the current page and store it in @page.
    #
    def load_page
      @page ||= if params[:urlname].present?
        # Load by urlname. If a language is specified in the request parameters,
        # scope pages to it to make sure we can raise a 404 if the urlname
        # is not available in that language.
        Page.contentpages.where(
          urlname:       params[:urlname],
          language_id:   Language.current.id,
          language_code: params[:lang] || Language.current.code
        ).first
      else
        # No urlname was given, so just load the language root for the
        # currently active language.
        Language.current_root_page
      end
    end

    def enforce_primary_host_for_site
      if needs_redirect_to_primary_host?
        redirect_to url_for(host: current_alchemy_site.host), :status => 301
      end
    end

    def needs_redirect_to_primary_host?
      current_alchemy_site.redirect_to_primary_host? &&
        current_alchemy_site.host != '*' &&
        current_alchemy_site.host != request.host
    end

    def render_page_or_redirect
      @page ||= load_page
      if signup_required?
        redirect_to signup_path
      elsif @page.nil? && last_legacy_url
        @page = last_legacy_url.page
        redirect_page
      elsif @page.blank?
        raise_not_found_error
      elsif multi_language? && params[:lang].blank?
        redirect_page(lang: Language.current.code)
      elsif multi_language? && params[:urlname].blank? && !params[:lang].blank? && configuration(:redirect_index)
        redirect_page(lang: params[:lang])
      elsif configuration(:redirect_to_public_child) && !@page.public?
        redirect_to_public_child
      elsif params[:urlname].blank? && configuration(:redirect_index)
        redirect_page
      elsif !multi_language? && !params[:lang].blank?
        redirect_page
      elsif @page.has_controller?
        redirect_to main_app.url_for(@page.controller_and_action)
      else
        # setting the language to page.language to be sure it's correct
        set_alchemy_language(@page.language)
        if params[:urlname].blank?
          @root_page = @page
        else
          @root_page = Language.current_root_page
        end
      end
    end

    def signup_required?
      if Alchemy.user_class.respond_to?(:admins)
        Alchemy.user_class.admins.size == 0 && @page.nil?
      end
    end

    def redirect_to_public_child
      @page = @page.self_and_descendants.published.not_restricted.first
      if @page
        redirect_page
      else
        raise_not_found_error
      end
    end

    def redirect_page(options={})
      defaults = {
        :lang => (multi_language? ? @page.language_code : nil),
        :urlname => @page.urlname
      }
      options = defaults.merge(options)
      redirect_to show_page_path(additional_params.merge(options)), :status => 301
    end

    def additional_params
      params.each do |key, value|
        params[key] = nil if ["action", "controller", "urlname", "lang"].include?(key)
      end
    end

    def legacy_urls
      LegacyPageUrl.joins(:page).where(urlname: params[:urlname], alchemy_pages: {language_id: Language.current.id})
    end

    def last_legacy_url
      legacy_urls.last
    end

    # Returns true if the page should be cached.
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
    # NOTE: Pages that are marked as searchresults are also not cached.
    #
    # @returns Boolean
    def cache_page?
      return false unless @page && Alchemy::Config.get(:cache_pages)
      pagelayout = PageLayout.get(@page.page_layout)
      pagelayout['cache'] != false && pagelayout['searchresults'] != true
    end

  end
end
