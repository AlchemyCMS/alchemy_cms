class PagesController < ApplicationController
  
  layout 'pages'
  
  before_filter :set_language_from_client, :only => [:show, :sitemap]
  before_filter :set_translation, :except => [:show, :preview]
  before_filter :get_page_from_urlname, :only => [:show, :sitemap]
  before_filter :get_page_from_id, :only => [:publish, :unlock, :preview, :edit, :update, :move, :fold, :destroy]
  
  filter_access_to [:show, :unlock, :publish, :preview, :edit, :edit_content, :update, :move, :destroy], :attribute_check => true
  filter_access_to [:index, :systempages, :new, :switch_language, :create_language, :create, :fold], :attribute_check => false
  
  caches_action(
    :show,
    :layout => false,
    :cache_path => Proc.new { |c| c.multi_language? ? "#{c.session[:language]}/#{c.params[:urlname]}" : "#{c.params[:urlname]}" },
    :if => Proc.new { |c| 
      if WaConfigure.parameter(:cache_pages)
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
  cache_sweeper :pages_sweeper, :if => Proc.new { |c| WaConfigure.parameter(:cache_pages) }
  
  def index
    @page_root = Page.find(
      :first,
      :include => [:children],
      :conditions => {:language_root_for => session[:language]}
    )
    if @page_root.nil?
      create_new_rootpage
      flash[:notice] = _("WaAdmin|new rootpage created")
    end
    render :layout => 'admin'
  end
  
  def fold
    # @page is fetched via before filter
    @page.fold(current_user.id, !@page.folded?(current_user.id))
    @page.save
    render :nothing => true
  end
  
  def systempages
    @system_root = Page.systemroot.first
    render :layout => 'admin'
  end
  
  def new
    @parent_id = params[:parent_id]
    @page = Page.new
    render :layout => false
  end
  
  def create
    begin
      parent = Page.find(params[:page][:parent_id])
      page_layout = PageLayout.get(params[:page][:page_layout])
      params[:page][:created_by] = current_user.id
      params[:page][:updated_by] = current_user.id
      params[:page][:language] = parent.language
      params[:page][:systempage] = ((page_layout["systempage"] == true) rescue false)
      page = Page.create(params[:page])
      if page.valid?
        page.move_to_child_of parent
      end
      render_errors_or_redirect(page, pages_path, _("page '%{name}' created.") % {:name => page.name})
    rescue
      log_error($!)
    end
  end
  
  def show
    # @page is fetched via before filter
    # rendering page and querying for search results if any query is present
    if configuration(:ferret) && !params[:query].blank?
      perform_search
    end
  end
  
  def preview
    # fetching page via before filter
  end
  
  def edit
    # fetching page via before filter
    render :layout => false
  end
  
  def update
    # fetching page via before filter
    @page.update_attributes(params[:page])
    render_errors_or_redirect(@page, request.referer, _("Page %{name} saved") % {:name => @page.name})
  end
  
  def destroy
    # fetching page via before filter
    name = @page.name
    if @page.destroy
      render :update do |page|
        page.replace_html(
          "sitemap",
          :partial => 'page',
          :object => Page.language_root(session[:language])
        )
        WaNotice.show_via_ajax(page, _("Page %{name} deleted") % {:name => name})
      end
    end
  end
  
  # Leaves the page editing mode and unlocks the page for other users
  def unlock
    # fetching page via before filter
    @page.unlock
    flash[:notice] = _("unlocked_page_%{name}") % {:name => @page.name}
    if params[:redirect_to].blank?
      redirect_to pages_path
    else
      redirect_to(params[:redirect_to])
    end
  end
  
  # Sweeps the page cache
  def publish
    # fetching page via before filter
    @page.save
    flash[:notice] = _("page_published") % {:name => @page.name}
    redirect_back_or_to_default(pages_path)
  end
  
  def move
    # fetching page via before filter
    @page_root = Page.language_root(session[:language])
    my_position = @page.self_and_siblings.index(@page)
    case params[:direction]
    when 'up'
      then
      @page.move_to_left_of @page.self_and_siblings[my_position - 1]
    when 'down'
      then 
      @page.move_to_right_of @page.self_and_siblings[my_position + 1]
    when 'left'
      then
      @page.move_to_right_of @page.parent
    when 'right'
      @page.move_to_child_of @page.self_and_siblings[my_position - 1]
    end
    # We have to save the page for triggering the cache_sweeper, because betternestedset uses transactions.
    # And the sweeper does not get triggered by transactions.
    @page.save
  end
  
  def edit_content
    @page = Page.find(
      params[:id],
      :include => {
        :elements => :contents
      }
    )
    @systempage = !params[:systempage].blank? && params[:systempage] == 'true'
    @created_by = User.find(@page.created_by).login rescue ""
    @updated_by = User.find(@page.updated_by).login rescue ""
    if @page.locked? && @page.locker != current_user
      flash[:notice] = _("This page is locked by %{name}") % {:name => (@page.locker.name rescue _('unknown'))}
      redirect_to pages_path
    else
      @page.lock(current_user)
      render :layout => 'admin'
    end
  end
  
  def create_language
    created_languages = Page.language_roots.collect(&:language)
    all_languages = WaConfigure.parameter(:languages).collect{ |l| [l[:language], l[:language_code]] }
    @languages = all_languages.select{ |lang| created_languages.include?(lang[1]) }
    lang = configuration(:languages).detect { |l| l[:language_code] == params[:language_code] }
    @language = [
      lang[:language],
      params[:language_code]
    ]
    render :layout => false
  end
  
  def copy_language
    set_language(params[:languages][:new_lang])
    begin
      # copy language root from old to new language
      original_language_root = Page.find_by_language_root_for(params[:languages][:old_lang])
      new_language_root = Page.copy(
        original_language_root,
        :language => params[:languages][:new_lang],
        :language_root_for => params[:languages][:new_lang],
        :public => false
      )
      new_language_root.move_to_child_of Page.root
      copy_child_pages(original_language_root, new_language_root)
      flash[:notice] = _('language_pages_copied')
    rescue
      log_error($!)
      flash[:notice] = _('language_pages_could_not_be_copied')
    end
    redirect_to :action => :index
  end
  
  # renders a Google conform sitemap in xml
  def sitemap
    @pages = Page.find_all_by_sitemap_and_public(true, true)
    respond_to do |format|
      format.xml { render :layout => "sitemap" }
    end
  end
  
  def sort
    #
  end
  
  def switch_language
    if Page.find_by_language_root_for(params[:language], :select => 'id').nil?
      title = _('create_new_language')
      render :update do |page|
        page << %(wa_overlay_window(
          '#{url_for(
            :controller => :pages,
            :action => :create_language,
            :language_code => params[:language]
          )}',
          '#{title}',
          255,
          200,
          false,
          'true',
          false
        ))
      end
    else
      set_language(params[:language])
      if request.xhr?
        render :update do |page|
          page.redirect_to pages_url
        end
      else
        redirect_to pages_url
      end
    end
  end
  
private
  
  def copy_child_pages(source_page, new_page)
    source_page.children.each do |child_page|
      new_child = Page.copy(child_page, :language => new_page.language, :public => false)
      new_child.move_to_child_of new_page
      unless child_page.children.blank?
        copy_child_pages(child_page, new_child)
      end
    end
  end
  
  def create_new_rootpage
    lang = configuration(:languages).detect{ |l| l[:language_code] == session[:language] }
    @page_root = Page.create(
      :name => lang[:frontpage_name],
      :page_layout => lang[:page_layout],
      :language => lang[:language_code],
      :language_root_for => lang[:language_code],
      :public => false,
      :visible => true
    )
    @page_root.move_to_child_of Page.root
  end
  
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
  
  def get_page_from_id
    @page = Page.find(params[:id])
  end
  
  def perform_search
    @rtf_search_results = EssenceRichtext.find_by_contents(
      "*" + params[:query] + "*",
      {:limit => :all},
      {:conditions => "public = 1"}
    )
    @text_search_results = EssenceText.find_by_contents(
      "*" + params[:query] + "*",
      {:limit => :all},
      {:conditions => "public = 1"}
    )
  end

end
