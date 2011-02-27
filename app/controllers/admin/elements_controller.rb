class Admin::ElementsController < AlchemyController
  
  layout 'alchemy'
  
  before_filter :set_translation
  
  filter_access_to [:new, :create, :order, :index], :attribute_check => false
  
  def index
    @page_id = params[:page_id]
    if @page_id.blank? && !params[:page_urlname].blank?
      @page_id = Page.find_by_urlname(params[:page_urlname]).id
    end
    @elements = Element.find_all_by_page_id_and_public(@page_id, true)
  end
  
  def list
    @page = Page.find(
      params[:page_id],
      :include => {
        :elements => :contents
      }
    )
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
    if params[:paste_from_clipboard].blank?
      @element = Element.new_from_scratch(params[:element])
    else
      source_element = Element.find(params[:paste_from_clipboard])
      if source_element.page_id == blank? # aka. move
        @element = source_element
        @element.page_id = params[:element][:page_id]
      else
        @element = Element.copy(source_element, { 
          :page_id => params[:element][:page_id]
        })
      end
    end
    if @element.save
      @richtext_contents = @element.contents.select { |content| content.essence_type == 'EssenceRichtext' }
      @page = @element.page
    else
      render_remote_errors(@element)
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  # Saves all contents in the elements by calling save_content on each content
  # And then updates the element itself.
  # If a Ferret::FileNotFoundError raises we gonna catch it and rebuilding the index.
  def update
    @element = Element.find_by_id(params[:id])
    @element.contents.each do |content|
      content.save_content(params[:contents]["content_#{content.id}"], :public => !params["public"].nil?)
    end
    @page = @element.page
    @element.public = !params[:public].nil?
    @element.save!
    @richtext_contents = @element.contents.select { |content| content.essence_type == 'EssenceRichtext' }
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
  
  # Deletes the element with ajax and sets session[:clipboard].nil
  def destroy
    @element = Element.find_by_id(params[:id])
    @page = @element.page
    if @element.destroy
      unless session[:clipboard].nil?
        session[:clipboard] = nil if session[:clipboard][:element_id] == params[:id]
      end
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def order
    for element in params[:element_ids]
      element = Element.find(element)
      element.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show(page, _("successfully_saved_element_position"))
      page << "Alchemy.PreviewWindow.refresh()"
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def fold
    @element = Element.find(params[:id])
    @element.folded = !@element.folded
    @element.save(false)
    @richtext_contents = @element.contents.select { |content| content.essence_type == 'EssenceRichtext' }
  rescue Exception => e
    exception_handler(e)
  end
  
end
