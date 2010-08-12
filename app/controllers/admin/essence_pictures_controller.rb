class Admin::EssencePicturesController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :all
  
  def edit
    @essence_picture = EssencePicture.find(params[:id])
    @options = params[:options]
    render :layout => false
  end
  
  def crop
    @essence_picture = EssencePicture.find(params[:id])
    if !@essence_picture.crop_from.blank? && !@essence_picture.crop_size.blank?
      @initial_box = {
        :x1 => @essence_picture.crop_from.split('x')[0].to_i,
        :y1 => @essence_picture.crop_from.split('x')[1].to_i,
        :x2 => @essence_picture.crop_from.split('x')[0].to_i + @essence_picture.crop_size.split('x')[0].to_i,
        :y2 => @essence_picture.crop_from.split('x')[1].to_i + @essence_picture.crop_size.split('x')[1].to_i
      }
    end
    @size_x = params[:size].split('x')[0]
    @size_y = params[:size].split('x')[1]
    render :layout => false
  end
  
  def update
    @essence_picture = EssencePicture.find(params[:id])
    @essence_picture.update_attributes(params[:essence_picture])
    render :update do |page|
      page << "Windows.getFocusedWindow().close()"
      page << "reloadPreview()"
    end
  end
  
  def assign
    @content = Content.find(params[:id])
    @picture = Picture.find(params[:picture_id])
    @content.essence.picture = @picture
    @content.essence.save
    @content.save
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
    render :update do |page|
      page.replace "picture_#{@content.id}", :partial => "essences/essence_picture_editor", :locals => {:content => @content, :options => @options}
      if @content.element.contents.find_all_by_essence_type("EssencePicture").size > 1
        Alchemy::Configuration.sortable_contents(page, @content.element)
      end
      page << "reloadPreview()"
      page << "Windows.getFocusedWindow().close()"
    end
  end
  
  def save_link
    @content = Content.find(params[:id])
    @picture_essence = @content.essence
    @picture_essence.link = params[:link]
    @picture_essence.link_title = params[:title]
    @picture_essence.open_link_in_new_window = params[:blank]
    if @picture_essence.save
      render :update do |page|
        page << "Windows.closeAll();reloadPreview()"
        Alchemy::Notice.show_via_ajax(page, _("saved_link"))
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
      page << "reloadPreview()"
    end
  end
  
end