module Alchemy
  class AttachmentsController < BaseController

    filter_access_to [:show, :download], :attribute_check => true, :model => Alchemy::Attachment, :load_method => :load_attachment

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
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
      send_file(
        @attachment.full_filename, {
          :name => @attachment.filename,
          :type => @attachment.content_type,
          :disposition => 'attachment'
        }
      )
    end

  private

    def load_attachment
      @attachment = Attachment.where(:id => params[:id]).first
    end

  end
end
