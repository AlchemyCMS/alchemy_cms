module Alchemy
  class PagesController < Alchemy::BaseController
    before_action :enforce_primary_host_for_site
    before_action :render_page_or_redirect, only: [:show]

    # Needs to be included after +before_action+ calls, to be sure the filters are appended.
    include OnPageLayout::CallbacksRunner

    # Showing page from params[:urlname]
    #
    def show
      authorize! :show, @page

      if render_fresh_page?
        respond_to do |format|
          format.html { render layout: !request.xhr? }
          format.rss do
            if @page.contains_feed?
              render layout: false, handlers: [:builder]
            else
              render xml: {error: 'Not found'}, status: 404
            end
          end
        end
      end
    rescue ActionController::UnknownFormat
      page_not_found!
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
          language_code: params[:locale] || Language.current.code
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
        redirect_to Alchemy.signup_path
      elsif (@page.nil? || request.format.nil?) && last_legacy_url
        @page = last_legacy_url.page
        # This drops the given query string.
        redirect_legacy_page
      elsif @page.blank?
        page_not_found!
      elsif multi_language? && params[:locale].blank?
        redirect_page(locale: Language.current.code)
      elsif multi_language? && params[:urlname].blank? && !params[:locale].blank? && configuration(:redirect_index)
        redirect_page(locale: params[:locale])
      elsif configuration(:redirect_to_public_child) && !@page.public?
        redirect_to_public_child
      elsif params[:urlname].blank? && configuration(:redirect_index)
        redirect_page
      elsif !multi_language? && !params[:locale].blank?
        redirect_page
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
      @page ? redirect_page : page_not_found!
    end

    # Redirects page to given url with 301 status while keeping all additional params
    def redirect_page(options = {})
      options = {
        locale: (multi_language? ? @page.language_code : nil),
        urlname: @page.urlname
      }.merge(options)

      redirect_to show_page_path(additional_params.merge(options)), status: 301
    end

    # Use the bare minimum to redirect to @page
    # Don't use query string of legacy urlname
    def redirect_legacy_page(options={})
      defaults = {
        locale: (multi_language? ? @page.language_code : nil),
        urlname: @page.urlname
      }
      options = defaults.merge(options)
      redirect_to show_page_path(options), status: 301
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

    def legacy_urls
      # /slug/tree => slug/tree
      urlname = (request.fullpath[1..-1] if request.fullpath[0] == '/') || request.fullpath
      LegacyPageUrl.joins(:page).where(urlname: urlname, Page.table_name => {language_id: Language.current.id})
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

    def page_not_found!
      not_found_error!("Alchemy::Page not found \"#{request.fullpath}\"")
    end
  end
end
