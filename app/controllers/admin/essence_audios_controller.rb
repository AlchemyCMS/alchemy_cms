class Admin::EssenceAudiosController < AlchemyController

  filter_access_to :update

  def update
    @essence_audio = EssenceAudio.find(params[:id])
    @essence_audio.update_attributes(params[:essence_audio])
  end

end
