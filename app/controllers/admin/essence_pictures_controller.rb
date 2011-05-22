class Admin::EssencePicturesController < AlchemyController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def edit
    @essence_picture = EssencePicture.find(params[:id])
    @content = Content.find(params[:content_id])
    @options = params[:options]
    render :layout => false
  end
  
  def crop
    @essence_picture = EssencePicture.find(params[:id])
    @content = Content.find(params[:content_id])
    @options = params[:options]
    if !@essence_picture.crop_from.blank? && !@essence_picture.crop_size.blank?
      @initial_box = {
        :x1 => @essence_picture.crop_from.split('x')[0].to_i,
        :y1 => @essence_picture.crop_from.split('x')[1].to_i,
        :x2 => @essence_picture.crop_from.split('x')[0].to_i + @essence_picture.crop_size.split('x')[0].to_i,
        :y2 => @essence_picture.crop_from.split('x')[1].to_i + @essence_picture.crop_size.split('x')[1].to_i
      }
    end
    @size_x, @size_y = 0, 0
    if params[:size]
      @size_x = params[:size].split('x')[0]
      @size_y = params[:size].split('x')[1]
    end
    render :layout => false
  end
  
  def update
    @essence_picture = EssencePicture.find(params[:id])
    @essence_picture.update_attributes(params[:essence_picture])
    @content = Content.find(params[:content_id])
  end
  
  def assign
    @content = Content.find(params[:id])
    @picture = Picture.find(params[:picture_id])
    @content.essence.picture = @picture
    @options = params[:options]
    # If options params come from Flash uploader then we have to parse them as hash.
    @element = @content.element
    contents_of_this_type = @element.contents.find_all_by_essence_type('EssencePicture')
    @dragable = contents_of_this_type.length > 1
    if @options.is_a?(String)
      @options = Rack::Utils.parse_query(@options)
    end
    @options = @options.merge(
      :dragable => @dragable
    )
  end
  
  def save_link
    @content = Content.find(params[:id])
    @picture_essence = @content.essence
    @picture_essence.link = params[:link]
    @picture_essence.link_title = params[:title]
    @picture_essence.open_link_in_new_window = params[:blank]
    if @picture_essence.save
      render :update do |page|
        page << "Alchemy.closeCurrentWindow()"
        page << "Alchemy.reloadPreview()"
        Alchemy::Notice.show(page, _("saved_link"))
      end
    end
  end
  
  def destroy
    content = Content.find_by_id(params[:id])
    element = content.element
    element.contents.delete content
    picture_contents = element.contents.find_all_by_essence_type("EssencePicture")
    render :update do |page|
      page.replace(
        "element_#{element.id}_contents",
        :partial => "admin/elements/picture_editor",
        :locals => {
          :picture_contents => picture_contents,
          :element => element,
          :options => params[:options]
        }
      )
      page << "Alchemy.reloadPreview()"
    end
  end
  
end