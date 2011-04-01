class Admin::ElementsController < AlchemyController
  
  layout 'alchemy'
  
  before_filter :set_translation
  
  filter_access_to [:new, :create, :order, :index], :attribute_check => false
  
  cache_sweeper :content_sweeper, :only => [:update]
  
  def index
    @page_id = params[:page_id]
    if @page_id.blank? && !params[:page_urlname].blank?
      @page_id = Page.find_by_urlname(params[:page_urlname]).id
    end
    @elements = Element.find_all_by_page_id_and_public(@page_id, true)
  end
  
  def list
    @page = Page.find(params[:page_id], :include => {:elements => :contents})
    @cells = @page.cells
    if @cells.blank?
      @elements = @page.elements
    else
      @elements = @page.elements_grouped_by_cells
    end
    render :layout => false
  end
  
  def new
    @page = Page.find_by_id(params[:page_id])
    @element = @page.elements.build
    @elements = Element.all_for_page(@page)
    @clipboard_items = Element.all_from_clipboard_for_page(get_clipboard('elements'), @page)
    render :layout => false
  end
  
  # Creates a element as discribed in config/alchemy/elements.yml on page via AJAX.
  # If a Ferret::FileNotFoundError raises we catch it and rebuilding the index.
  def create
    @page = Page.find(params[:element][:page_id])
    if params[:paste_from_clipboard].blank?
      @element = Element.new_from_scratch(params[:element])
    else
      source_element = Element.find(params[:paste_from_clipboard])
      if source_element.page_id == blank? # aka. move
        @element = source_element
      else
        @element = Element.copy(source_element, {:page_id => @page.id})
      end
    end
    # if page has cells, put element in cell
    if @page.has_cells?
      cell_definition = Cell.definition_for_element(@element.name)
      if cell_definition
        @cell = @page.cells.find_or_create_by_name(cell_definition['name'])
      end
      @element.cell = @cell
    end
    @element.page = @page
    if @element.save
      render :action => :create
    else
      render_remote_errors(@element, 'form#new_element button.button')
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  # Saves all contents in the elements by calling save_content on each content
  # And then updates the element itself.
  # If a Ferret::FileNotFoundError raises we gonna catch it and rebuilding the index.
  def update
    @element = Element.find_by_id(params[:id])
    if @element.save_contents(params)
      @page = @element.page
      @element.public = !params[:public].nil?
      @element.save
    else
      render :update do |page|
        Alchemy::Notice.show(page, _("Validation failed."), :warn)
        error_message = "<h2>#{_('Validation failed.')}</h2><p>#{_('Please check contents below.')}</p>"
        page << "jQuery('#element_#{@element.id}_errors').html('#{error_message}<ul><li>#{@element.essence_error_messages.join('</li><li>')}</li></ul>')"
        page.show("element_#{@element.id}_errors")
        selector = @element.contents_with_errors.map { |content| '#' + content_dom_id(content) }.join(', ')
        page << "jQuery('div.content_editor').removeClass('validation_failed')"
        page << "jQuery('#{selector}').addClass('validation_failed')"
        page << "Alchemy.enableButton('#element_#{@element.id} button.button')"
      end
    end
  rescue Exception => e
    exception_logger(e)
    if e.class == Ferret::FileNotFoundError
      EssenceText.rebuild_index
      EssenceRichtext.rebuild_index
      render :update do |page|
        Alchemy::Notice.show(page, _("Index Error after saving Element. Please try again!"), :error)
      end
    else
      show_error_notice(e)
    end
  end
  
  # Trashes the Element instead of deleting it.
  def trash
    @element = Element.find(params[:id])
    @page_id = @element.page.id
    @element.trash
  rescue Exception => e
    exception_handler(e)
  end
  
  def order
    page = Page.find(params[:page_id])
    for element in params[:element_ids]
      element = Element.find(element)
      if element.trashed?
        element.page = page
      end
      element.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show(page, _("successfully_saved_element_position"))
      page << "jQuery('#element_area .ajax_folder').show()"
      page << "Alchemy.PreviewWindow.refresh()"
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def fold
    @element = Element.find(params[:id])
    @page = @element.page
    @element.folded = !@element.folded
    @element.save(false)
  rescue Exception => e
    exception_handler(e)
  end
  
end
