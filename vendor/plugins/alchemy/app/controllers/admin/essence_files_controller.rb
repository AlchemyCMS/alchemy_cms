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
    @attachement = Attachement.find_by_id(params[:attachement_id])
    @content.essence.file = @attachement
    @content.essence.save
    @content.save
    render :update do |page|
      page.replace "file_#{@content.id}", :partial => "contents/essence_file_editor", :locals => {:content => @content, :options => params[:options]}
      page << "reloadPreview();alchemy_window.close()"
    end
  end
  
end