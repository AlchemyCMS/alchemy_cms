class PagesController < AlchemyController
  
  before_filter :set_language_from_client, :only => [:show, :sitemap]
  before_filter :get_page_from_urlname, :only => [:show, :sitemap]

  filter_access_to :show, :attribute_check => true

  caches_action(
    :show,
    :layout => false,
    :cache_path => Proc.new { |c| c.multi_language? ? "#{session[:language_code]}/#{c.params[:urlname]}" : "#{c.params[:urlname]}" },
    :if => Proc.new { |c| 
      if Alchemy::Config.get(:cache_pages)
        page = Page.find_by_urlname_and_language_id_and_public(
          c.params[:urlname],
          session[:language_id],
          true,
          :select => 'page_layout, language_id, urlname'
        )
        if page
          pagelayout = Alchemy::PageLayout.get(page.page_layout)
          pagelayout['cache'].nil? || pagelayout['cache']
        end
      else
        false
      end
    }
  )

  # Showing page from params[:urlname]
  # @page is fetched via before filter
  # @root_page is fetched via before filter
  # @language fetched via before_filter in alchemy_controller
  # rendering page and querying for search results if any query is present
  def show
    if configuration(:ferret) && !params[:query].blank?
      perform_search
    end
    render :layout => params[:layout].blank? ? 'pages' : params[:layout] == 'none' ? false : params[:layout]
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
      @page = Page.language_root_for(Language.get_default.id)
    else
      @page = Page.find_by_urlname_and_language_id(params[:urlname], session[:language_id])
      # try to find the page in another language
      if @page.nil?
        @page = Page.find_by_urlname(params[:urlname])
      end
    end
    if User.admins.count == 0 && @page.nil?
      redirect_to signup_path
    elsif @page.blank?
      render(:file => "#{Rails.root}/public/404.html", :status => 404, :layout => false)
    elsif multi_language? && params[:lang].blank?
      redirect_to show_page_path(:urlname => @page.urlname, :lang => session[:language_code]), :status => 301
    elsif multi_language? && params[:urlname].blank? && !params[:lang].blank?
      redirect_to show_page_path(:urlname => @page.urlname, :lang => params[:lang]), :status => 301
    elsif configuration(:redirect_to_public_child) && !@page.public?
      redirect_to_public_child
    elsif !multi_language? && !params[:lang].blank?
      redirect_to show_page_path(:urlname => @page.urlname), :status => 301
    elsif @page.has_controller?
      redirect_to(@page.controller_and_action)
    else
      # setting the language to page.language to be sure it's correct
      set_language_to(@page.language_id)
      if params[:urlname].blank?
        @root_page = @page
      else
        @root_page = Page.language_root_for(session[:language_id])
      end
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
    if @page.blank?
      render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    else
      redirect_page
    end
  end

  def redirect_page
    get_additional_params
    redirect_to(
      send(:show_page_path, {
        :lang => (multi_language? ? @page.language_code : nil),
        :urlname => @page.urlname
      }.merge(@additional_params)),
      :status => 301
    )
  end

  def get_additional_params
    @additional_params = params.clone.delete_if do |key, value|
      ["action", "controller", "urlname", "lang"].include?(key)
    end
  end

end
