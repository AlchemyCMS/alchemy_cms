class Admin::EssenceFilesController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :all
  
  def edit
    @content = Content.find(params[:id])
    @essence_file = @content.essence
    render :layout => false
  end
  
  def update
    @essence_file = EssenceFile.find(params[:id])
    @essence_file.update_attributes(params[:essence_file])
    render :update do |page|
      page << "alchemy_window.close(); reloadPreview()"
    end
  end
  
  def assign
    @content = Content.find_by_id(params[:id])
    @attachment = Attachment.find_by_id(params[:attachment_id])
    @content.essence.attachment = @attachment
    @content.essence.save
    @content.save
    render :update do |page|
      page.replace "file_#{@content.id}", :partial => "essences/essence_file_editor", :locals => {:content => @content, :options => params[:options]}
      page << "reloadPreview();alchemy_window.close()"
    end
  end
  
end