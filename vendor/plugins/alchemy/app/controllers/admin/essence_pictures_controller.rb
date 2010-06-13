class Admin::EssencePicturesController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :all
  
  def edit
    @essence_picture = EssencePicture.find(params[:id])
    @options = params[:options]
    render :layout => false
  end
  
  def update
    @essence_picture = EssencePicture.find(params[:id])
    @essence_picture.update_attributes(params[:essence_picture])
    render :update do |page|
      page << "alchemy_window.close(); reloadPreview()"
    end
  end
  
  def assign
    @content = Content.find_by_id(params[:id])
    @image = Image.find_by_id(params[:image_id])
    @content.essence.image = @image
    @content.essence.save
    @content.save
    render :update do |page|
      dom_string = params[:swap] ? "picture" : "assign_content_#{@content.element.id}"
      page.replace "#{dom_string}_#{@content.id}", :partial => "essences/essence_picture_editor", :locals => {:content => @content, :options => params[:options]}
      if @content.element.contents.find_all_by_essence_type("EssencePicture").size > 1
        Alchemy::Configuration.sortable_atoms(page, @content.element)
      end
      page << "reloadPreview()"
      page << "alchemy_window.close()"
    end
  end
  
  def save_link
    @atom = Content.find(params[:id])
    @picture_atom = @atom.atom
    @picture_atom.link = params[:link]
    @picture_atom.link_title = params[:title]
    @picture_atom.open_link_in_new_window = params[:blank]
    if @picture_atom.save
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