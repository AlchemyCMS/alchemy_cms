class Admin::ContentsController < AlchemyController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def new
    @element = Element.find(params[:element_id])
    @contents = @element.available_contents
    @content = @element.contents.build
    render :layout => false
  end
  
  def create
    begin
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
        )
        unless params[:picture_id].blank?
          @content.essence.picture_id = params[:picture_id]
          @content.essence.save
        end
      end
    rescue Exception => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("content_not_successfully_added"), :error)
      end
    end
  end
  
  def update
    content = Content.find(params[:id])
    content.content.update_attributes(params[:content])
    render :update do |page|
      page << "alchemy_window.close();reloadPreview()"
    end
  end
  
  def order
    element = Element.find(params[:element_id])
    for content_id in params["element_#{element.id}_contents"]
      content = Content.find(content_id)
      content.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show_via_ajax(page, _("Successfully saved content position"))
      page << "reloadPreview()"
    end
  end
  
  def destroy
    begin
      content = Content.find(params[:id])
      element = content.element
      content_name = content.name
      content_dom_id = "#{content.essence_type.underscore}_#{content.id}"
      if content.destroy
        render :update do |page|
          page.remove(content_dom_id)
          Alchemy::Notice.show_via_ajax(page, _("Successfully deleted %{content}") % {:content => content_name})
          page << "reloadPreview()"
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("content_not_successfully_deleted"), :error)
      end
    end
  end
  
end
