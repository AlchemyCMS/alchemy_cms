class Admin::EssenceVideosController < AlchemyController
  
  layout 'alchemy'
  
  filter_access_to :update
  
  def update
    @essence_video = EssenceVideo.find(params[:id])
    @essence_video.update_attributes(params[:essence_video])
    render :update do |page|
      page << "Alchemy.closeCurrentWindow(); Alchemy.reloadPreview()"
    end
  end
  
end