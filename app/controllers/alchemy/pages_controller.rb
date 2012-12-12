module Alchemy
  class PagesController < Alchemy::BaseController
    include Alchemy::FerretSearch

    # We need to include this helper because we need the breadcrumb method.
    # And we cannot define the breadcrump method as helper_method, because rspec does not see helper_methods.
    # Not the best solution, but's working.
    # Anyone with a better idea please provide a patch.
    include Alchemy::BaseHelper

    rescue_from ActionController::RoutingError, :with => :render_404

    before_filter :render_page_or_redirect, :only => [:show, :sitemap]
    before_filter :perform_search, :only => :show, :if => proc { configuration(:ferret) }

    filter_access_to :show, :attribute_check => true, :model => Alchemy::Page, :load_method => :load_page

    caches_action(:show,
      :cache_path => proc { @page.cache_key(request) },
      :if => proc {
        if @page && Alchemy::Config.get(:cache_pages)
          pagelayout = PageLayout.get(@page.page_layout)
          if (pagelayout['cache'].nil? || pagelayout['cache']) && pagelayout['searchresults'] != true
            true
          end
        else
          false
        end
      }, :layout => false)

    layout :layout_for_page

    # Showing page from params[:urlname]
    # @page is fetched via before filter
    # @root_page is fetched via before filter
    # @language fetched via before_filter in alchemy_controller
    # querying for search results if any query is present via before_filter
    def show
      respond_to do |format|
        format.html { render }
        format.rss {
          if @page.contains_feed?
            render :action => "show", :layout => false, :handlers => [:builder]
          else
            render :xml => {:error => 'Not found'}, :status => 404
          end
        }
      end
    end

    # Renders a Google conform sitemap in xml
    def sitemap
      @pages = Page.find_all_by_sitemap_and_public(true, true)
      respond_to do |format|
        format.xml { render :layout => "sitemap" }
      end
    end

  private

    def load_page
      # we need this, because of a dec_auth bug (it calls this method after the before_filter again).
      return @page if @page
      if params[:urlname].blank?
        @page = Page.language_root_for(Language.get_default.id)
      else
        if params[:lang].blank?
          @page = Page.contentpages.where(urlname: params[:urlname], language_id: Language.get_default).first
          store_language_in_session(@page.language) if @page.present?
          return @page
        else
          @page = Page.contentpages.where(
            :urlname => params[:urlname],
            :language_id => session[:language_id],  # Make sure that the current language
            :language_code => params[:lang]         # matches the requested language code.
          ).first
        end
      end
    end

    def render_page_or_redirect
      @page ||= load_page
      if User.admins.count == 0 && @page.nil?
        redirect_to signup_path
      elsif @page.blank?
        raise_not_found_error
      elsif multi_language? && params[:lang].blank?
        redirect_page(:lang => session[:language_code])
      elsif multi_language? && params[:urlname].blank? && !params[:lang].blank? && configuration(:redirect_index)
        redirect_page(:lang => params[:lang])
      elsif configuration(:redirect_to_public_child) && !@page.public?
        redirect_to_public_child
      elsif params[:urlname].blank? && configuration(:redirect_index)
        redirect_page
      elsif !multi_language? && !params[:lang].blank?
        redirect_page
      elsif configuration(:url_nesting) && url_levels.any? && !levels_are_in_page_branch?
        raise_not_found_error
      elsif configuration(:url_nesting) && should_be_nested? && !url_levels.any?
        redirect_page(params_for_nested_url)
      elsif !configuration(:url_nesting) && url_levels.any?
        redirect_page
      elsif @page.has_controller?
        redirect_to main_app.url_for(@page.controller_and_action)
      else
        # setting the language to page.language to be sure it's correct
        set_language_from(@page.language_id)
        if params[:urlname].blank?
          @root_page = @page
        else
          @root_page = Page.language_root_for(session[:language_id])
        end
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
        params[key] = nil if ["action", "controller", "urlname", "lang", "level1", "level2", "level3"].include?(key)
      end
    end

    def url_levels
      params.keys.grep(/^level[1-3]$/)
    end

    def levels_are_in_page_branch?
      nested_urlnames = breadcrumb(@page).collect(&:urlname)
      level_names = params.select { |k, v| url_levels.include?(k) }.map(&:second)
      level_names & nested_urlnames == level_names
    end

    def should_be_nested?
      !params_for_nested_url.blank?
    end

  end
end
