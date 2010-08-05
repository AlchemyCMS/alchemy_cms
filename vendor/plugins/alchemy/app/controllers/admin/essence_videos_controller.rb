class Admin::EssenceVideosController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :update
  
  def update
    @essence_video = EssenceVideo.find(params[:id])
    @essence_video.update_attributes(params[:essence_video])
    render :update do |page|
      page << "alchemy_window.close(); reloadPreview()"
    end
  end
  
end