class AttachmentsController < AlchemyController
  
  # sends file inline. i.e. for viewing pdfs/movies in browser
  def show
    @attachment = Attachment.find(params[:id])
    send_file(
      @attachment.public_filename,
      {
        :name => @attachment.filename,
        :type => @attachment.content_type,
        :disposition => 'inline'
      }
    )
  end
  
  # sends file as attachment. aka download
  def download
    @attachment = Attachment.find(params[:id])
    send_file(
      @attachment.full_filename, {
        :name => @attachment.filename,
        :type => @attachment.content_type,
        :disposition => 'attachment'
      }
    )
  end
  
end