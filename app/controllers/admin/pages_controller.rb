class Admin::PagesController < AlchemyController
  
  helper :pages
  
  layout 'alchemy'
  
  before_filter :set_translation, :except => [:show]
  before_filter :get_page_from_id, :only => [:show, :unlock, :visit, :publish, :configure, :edit, :update, :destroy, :fold]
  
  filter_access_to [:show, :unlock, :visit, :publish, :configure, :edit, :update, :destroy], :attribute_check => true
  filter_access_to [:index, :link, :layoutpages, :new, :switch_language, :create, :fold, :move, :flush], :attribute_check => false
  
  cache_sweeper :pages_sweeper, :only => [:publish], :if => Proc.new { |c| Alchemy::Configuration.parameter(:cache_pages) }
  
  def index
    @page_root = Page.language_root_for(session[:language_id])
    @locked_pages = Page.all_locked_by(current_user)
  end
  
  def show
    # fetching page via before filter
    @preview_mode = true
    set_language_to(@page.language_id)
    @root_page = Page.language_root_for(session[:language_id])
    render :layout => params[:layout].blank? ? 'pages' : params[:layout] == 'none' ? false : params[:layout]
  end
  
  def new
    @page = Page.new(:layoutpage => params[:layoutpage] == 'true', :parent_id => params[:parent_id])
    @page_layouts = Alchemy::PageLayout.get_layouts_for_select(session[:language_id], @page.layoutpage?)
    @clipboard_items = Page.all_from_clipboard_for_select(get_clipboard('pages'), session[:language_id], @page.layoutpage?)
    render :layout => false
  end
  
  def create
    parent = Page.find_by_id(params[:page][:parent_id]) || Page.root
    params[:page][:language_id] ||= parent.language ? parent.language.id : Language.get_default.id
    params[:page][:language_code] ||= parent.language ? parent.language.code : Language.get_default.code
    if !params[:paste_from_clipboard].blank?
      source_page = Page.find(params[:paste_from_clipboard])
      page = Page.copy(source_page, {
        :name => params[:page][:name].blank? ? source_page.name + ' (' + _('Copy') + ')' : params[:page][:name],
        :urlname => '',
        :title => '',
        :parent_id => params[:page][:parent_id],
        :language => parent.language
      })
      source_page.copy_children_to(page) unless source_page.children.blank?
    else
      page = Page.create(params[:page])
    end
    if page.valid? && parent
      page.move_to_child_of(parent)
    end
    render_errors_or_redirect(page, parent.layoutpage? ? layoutpages_admin_pages_path : admin_pages_path, _("page '%{name}' created.") % {:name => page.name}, 'form#new_page_form button.button')
  rescue Exception => e
    exception_handler(e)
  end
  
  # Edit the content of the page and all its elements and contents.
  def edit
    # fetching page via before filter
    if @page.locked? && @page.locker.logged_in? && @page.locker != current_user
      flash[:notice] = _("This page is locked by %{name}") % {:name => (@page.locker.name rescue _('unknown'))}
      redirect_to admin_pages_path
    else
      @page.lock(current_user)
    end
    @layoutpage = @page.layoutpage?
  end
  
  # Set page configuration like page names, meta tags and states.
  def configure
    # fetching page via before filter
    if @page.redirects_to_external?
      render :action => 'configure_external', :layout => false
    else
      render :layout => false
    end
  end
  
  def update
    # fetching page via before filter
    if @page.update_attributes(params[:page])
      @notice = _("Page %{name} saved") % {:name => @page.name}
    else
      render_remote_errors(@page, "form#edit_page_#{@page.id} button.button")
    end
  end
  
  def destroy
    # fetching page via before filter
    name = @page.name
    page_id = @page.id
    layoutpage = @page.layoutpage?
    if @page.destroy
      get_clipboard('pages').delete(@page.id)
      render :update do |page|
        page.remove("locked_page_#{page_id}")
        message = _("Page %{name} deleted") % {:name => name}
        if layoutpage
          flash[:notice] = message
          page.redirect_to layoutpages_admin_pages_url
        else
          Alchemy::Notice.show(page, message)
          @page_root = Page.language_root_for(session[:language_id])
          if @page_root
            page.replace("sitemap", :partial => 'sitemap')
            page << "Alchemy.Tooltips()"
          else
            page.redirect_to admin_pages_url
          end
        end
      end
    end
  end
  
  def link
    @url_prefix = ""
    if configuration(:show_real_root)
      @page_root = Page.root
    else
      @page_root = Page.language_root_for(session[:language_id])
    end
    @area_name = params[:area_name]
    @content_id = params[:content_id]
    if params[:link_urls_for] == "newsletter"
      # TODO: links in newsletters has to go through statistic controller. therfore we have to put a string inside the content_rtfs and replace this string with recipient.id before sending the newsletter.
      #@url_prefix = "#{current_server}/recipients/reacts"
      @url_prefix = current_server
    end
    if multi_language?
      @url_prefix = "#{session[:language_code]}/"
    end
    render :layout => false
  end
  
  def fold
    # @page is fetched via before filter
    @page.fold(current_user.id, !@page.folded?(current_user.id))
    @page.save
    render :update do |page|
      page.replace "page_#{@page.id}", :partial => 'page', :locals => {:page => @page}
      page << "Alchemy.Tooltips()"
    end
  end
  
  def layoutpages
    @locked_pages = Page.all_locked_by(current_user)
    @layout_root = Page.find_or_create_layout_root_for(session[:language_id])
  end
  
  # Leaves the page editing mode and unlocks the page for other users
  def unlock
    # fetching page via before filter
    @page.unlock
    flash[:notice] = _("unlocked_page_%{name}") % {:name => @page.name}
    if request.xhr?
      render :update do |page|
        page.remove "locked_page_#{@page.id}"
        page << "jQuery('#page_#{@page.id} .site_status').removeClass('locked')"
        if Page.all_locked_by(current_user).blank?
          page << "jQuery('#subnav_additions label').hide()"
        end
        Alchemy::Notice.show(page, flash[:notice])
      end
    else
      if params[:redirect_to].blank?
        redirect_to admin_pages_path
      else
        redirect_to(params[:redirect_to])
      end
    end
  end
  
  def visit
    @page.unlock
    redirect_to multi_language? ? show_page_with_language_path(:lang => @page.language_code, :urlname => @page.urlname) : show_page_path(@page.urlname)
  end
  
  # Sets the page public and sweeps the page cache
  def publish
    # fetching page via before filter
    @page.public = true
    @page.save
    flash[:notice] = _("page_published") % {:name => @page.name}
    redirect_back_or_to_default(admin_pages_path)
  end
  
  def copy_language
    set_language_to(params[:languages][:new_lang_id])
    begin
      # copy language root from old to new language
      if params[:layoutpage]
        original_language_root = Page.layout_root_for(params[:languages][:old_lang_id])
      else
        original_language_root = Page.language_root_for(params[:languages][:old_lang_id])
      end
      new_language_root = Page.copy(
        original_language_root,
        :language_id => params[:languages][:new_lang_id],
        :language_code => Alchemy::Controller.current_language.code,
        :layoutpage => params[:layoutpage]
      )
      new_language_root.move_to_child_of Page.root
      original_language_root.copy_children_to(new_language_root)
      flash[:notice] = _('language_pages_copied')
    rescue
      exception_logger($!)
    end
    redirect_to :action => params[:layoutpage] == "true" ? :layoutpages : :index
  end
  
  def sort
    @page_root = Page.language_root_for(session[:language_id])
    @sorting = !params[:sorting]
  end
  
  def order
    @page_root = Page.language_root_for(session[:language_id])
    pages_from_raw_request.each do |page|
      page_id = page.first[0]
      parent_id = page.first[1]
      if parent_id == 'root'
        parent = @page_root
      else
        parent = Page.find(parent_id)
      end
      page = Page.find(page_id)
      page.move_to_child_of(parent)
    end
    render :update do |page|
      Alchemy::Notice.show(page, _("Pages order saved"))
      page.replace 'sitemap', :partial => 'sitemap'
      page.hide "bottom_panel"
      page << "jQuery('#page_sorting_button').removeClass('active')"
      page << "Alchemy.pleaseWaitOverlay(false)"
      page << "Alchemy.Tooltips()"
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def switch_language
    set_language_to(params[:language_id])
    redirect_path = params[:layoutpages] ? admin_layoutpages_path : admin_pages_path
    if request.xhr?
      render :update do |page|
        page.redirect_to redirect_path
      end
    else
      redirect_to redirect_path
    end
  end
  
  def flush
    Page.flushables(session[:language_id]).each do |page|
      if multi_language?
        expire_action("#{page.language_code}/#{page.urlname}")
      else
        expire_action("#{page.urlname}")
      end
    end
    render :update do |page|
      Alchemy::Notice.show(page, _('Page cache flushed'))
    end
  end
  
private
  
  def get_page_from_id
    @page = Page.find(params[:id])
  end
  
  def pages_from_raw_request
    request.raw_post.split('&').map { |i| i = {i.split('=')[0].gsub(/[^0-9]/, '') => i.split('=')[1]} }
  end
  
end
