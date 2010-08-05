class Admin::EssenceAudiosController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :update
  
  def update
    @essence_audio = EssenceAudio.find(params[:id])
    @essence_audio.update_attributes(params[:essence_audio])
    render :update do |page|
      page << "alchemy_window.close(); reloadPreview()"
    end
  end
  
end