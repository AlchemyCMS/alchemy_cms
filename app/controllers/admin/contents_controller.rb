class Admin::ContentsController < AlchemyController
  
  filter_access_to :all
  
  def new
    @element = Element.find(params[:element_id])
    @contents = @element.available_contents
    @content = @element.contents.build
    render :layout => false
  end
  
  def create
    @element = Element.find(params[:content][:element_id])
    @content = Content.create_from_scratch(@element, params[:content])
    @options = params[:options]
    # If options params come from Flash uploader then we have to parse them as hash.
    if @options.is_a?(String)
      @options = Rack::Utils.parse_query(@options)
    end
    if @content.essence_type == "EssencePicture"
      @contents_of_this_type = @element.contents.find_all_by_essence_type('EssencePicture')
      @dragable = @contents_of_this_type.length > 1
      @options = @options.merge(
        :dragable => @dragable
      ) if @options
      @content.essence.picture = Picture.find(params[:picture_id])
      @content.essence.save
    end
  rescue
    exception_handler($!)
  end
  
  def update
    content = Content.find(params[:id])
    content.content.update_attributes(params[:content])
    render :update do |page|
      page << "Alchemy.closeCurrentWindow();Alchemy.reloadPreview()"
    end
  end
  
  def order
    for id in params[:content_ids]
      content = Content.find(id)
      content.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show(page, _("Successfully saved content position"))
      page << "Alchemy.SortableContents('#element_area .picture_gallery_images', '#{form_authenticity_token}')"
      page << "Alchemy.reloadPreview()"
    end
  end
  
  def destroy
    content = Content.find(params[:id])
    element = content.element
    content_name = content.name
    content_dom_id = "#{content.essence_type.underscore}_#{content.id}"
    if content.destroy
      render :update do |page|
        page.remove(content_dom_id)
        Alchemy::Notice.show(page, _("Successfully deleted %{content}") % {:content => content_name})
        page << "Alchemy.reloadPreview()"
      end
    end
  rescue
    exception_handler($!)
  end
  
end
