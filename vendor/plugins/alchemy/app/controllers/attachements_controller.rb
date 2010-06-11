class AttachementsController < ApplicationController
  
  # sends file inline. i.e. for viewing pdfs/movies in browser
  def show
    @attachement = Attachement.find(params[:id])
    send_file(
      "#{RAILS_ROOT}/public" + @attachement.public_filename, {
        :name => @attachement.filename,
        :type => @attachement.content_type,
        :disposition => 'inline'
      }
    )
  end
  
  # sends file as attachment. aka download
  def download
    @attachement = Attachement.find(params[:id])
    send_file(
      @attachement.full_filename, {
        :name => @attachement.filename,
        :type => @attachement.content_type,
        :disposition => 'attachment'
      }
    )
  end
  
end