class Admin::EssenceFilesController < AlchemyController

  filter_access_to :all

  def edit
    @content = Content.find(params[:id])
    @essence_file = @content.essence
    render :layout => false
  end

  def update
    @essence_file = EssenceFile.find(params[:id])
    @essence_file.update_attributes(params[:essence_file])
  end

  def assign
    @content = Content.find_by_id(params[:id])
    @attachment = Attachment.find_by_id(params[:attachment_id])
    @content.essence.attachment = @attachment
    @content.essence.save
    @content.save
    @options = params[:options]
  end

end
