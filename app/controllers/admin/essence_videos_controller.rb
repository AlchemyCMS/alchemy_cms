class Admin::EssenceVideosController < AlchemyController

  filter_access_to :update

  def update
    @essence_video = EssenceVideo.find(params[:id])
    @essence_video.update_attributes(params[:essence_video])
  end

end
