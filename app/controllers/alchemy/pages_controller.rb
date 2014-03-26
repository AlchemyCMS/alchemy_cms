module Alchemy
  class PagesController < Alchemy::BaseController
    # We need to include this helper because we need the breadcrumb method.
    # And we cannot define the breadcrump method as helper_method, because rspec does not see helper_methods.
    # Not the best solution, but's working.
    # Anyone with a better idea please provide a patch.
    include Alchemy::BaseHelper

    rescue_from ActionController::RoutingError, :with => :render_404

    before_filter :enforce_primary_host_for_site
    before_filter :render_page_or_redirect, :only => [:show]
    before_filter :load_page
    authorize_resource only: 'show'

    # Showing page from params[:urlname]
    #
    def show
      if render_fresh_page?
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
    # Note: This only sets the cache control headers and skips rendering of the page body, if the cache is fresh.
    # This does not disable the fragment caching in the views. So if you don't want a page and it's elements to be cached,
    # then be sure to not use <% cache element %> in the views.
    #
    # @returns Boolean
    #
    def cache_page?
      return false unless @page && Alchemy::Config.get(:cache_pages)
      page_layout = PageLayout.get(@page.page_layout)
      page_layout['cache'] != false && page_layout['searchresults'] != true
    end

    # Returns the etag used for response headers.
    #
    # If a user is logged in, we append theirs etag to prevent caching of user related content.
    #
    # IMPORTANT: If your user does not have a +cache_key+ method (i.e. it's not an ActiveRecord model),
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

  end
end
