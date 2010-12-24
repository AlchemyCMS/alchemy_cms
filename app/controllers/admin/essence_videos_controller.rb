class Admin::EssenceVideosController < AlchemyController
  
  layout 'alchemy'
  
  filter_access_to :update
  
  def update
    @essence_video = EssenceVideo.find(params[:id])
    @essence_video.update_attributes(params[:essence_video])
    render :update do |page|
      page << "AlchemyWindow.dialog('close'); reloadPreview()"
    end
  end
  
end