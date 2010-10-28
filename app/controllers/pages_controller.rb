class PagesController < AlchemyController
  
  before_filter :set_language_from_client, :only => [:show, :sitemap]
  before_filter :get_page_from_urlname, :only => [:show, :sitemap]
  
  filter_access_to :show, :attribute_check => true
  
  caches_action(
    :show,
    :layout => false,
    :cache_path => Proc.new { |c| c.multi_language? ? "#{c.session[:language]}/#{c.params[:urlname]}" : "#{c.params[:urlname]}" },
    :if => Proc.new { |c| 
      if Alchemy::Configuration.parameter(:cache_pages)
        page = Page.find_by_urlname_and_language_and_public(
          c.params[:urlname],
          Alchemy::Controller.current_language,
          true,
          :select => 'page_layout, language, urlname'
        )
        if page
          pagelayout = PageLayout.get(page.page_layout)
          pagelayout['cache'].nil? || pagelayout['cache']
        end
      else
        false
      end
    }
  )
  
  def show
    # @page is fetched via before filter
    # rendering page and querying for search results if any query is present
    if configuration(:ferret) && !params[:query].blank?
      perform_search
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
  
  def get_page_from_urlname
    if params[:urlname].blank?
      @page = Page.find_by_language_root_for(session[:language])
    else
      @page = Page.find_by_urlname_and_language(params[:urlname], session[:language])
    end
    if @page.blank?
      render(:file => "#{RAILS_ROOT}/public/404.html", :status => 404)
    elsif @page.has_controller?
      redirect_to(@page.controller_and_action)
    elsif configuration(:redirect_to_public_child) && !@page.public?
      redirect_to_public_child
    elsif multi_language? && params[:lang].blank?
      redirect_to show_page_with_language_path(:urlname => @page.urlname, :lang => session[:language])
    end
  end
  
  def perform_search
    @rtf_search_results = EssenceRichtext.find_with_ferret(
      "*" + params[:query] + "*",
      {:limit => :all},
      {:conditions => "public = 1"}
    )
    @text_search_results = EssenceText.find_with_ferret(
      "*" + params[:query] + "*",
      {:limit => :all},
      {:conditions => "public = 1"}
    )
  end
  
  def find_first_public(page)
    if(page.public == true)
      return page
    end
    page.children.each do |child|
      result = find_first_public(child)
      if(result!=nil)
        return result
      end
    end
    return nil
  end
  
  def redirect_to_public_child
    @page = find_first_public(@page)
    if @page
      redirect_page
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end
  end
  
  def redirect_page
    get_additional_params
    redirect_to(
      send(
        "show_page_#{multi_language? ? 'with_language_' : nil }path".to_sym, {
          :lang => (multi_language? ? @page.language : nil),
          :urlname => @page.urlname
        }.merge(@additional_params)
      ),
      :status => 301
    )
  end
  
  def get_additional_params
    @additional_params = params.clone.delete_if do |key, value|
      ["action", "controller", "urlname", "lang"].include?(key)
    end
  end
  
end
