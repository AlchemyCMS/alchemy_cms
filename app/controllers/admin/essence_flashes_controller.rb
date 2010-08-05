class Admin::EssenceFlashesController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :update
  
  def update
    @essence_flash = EssenceFlash.find(params[:id])
    @essence_flash.update_attributes(params[:essence_flash])
    render :update do |page|
      page << "alchemy_window.close(); reloadPreview()"
    end
  end
  
end