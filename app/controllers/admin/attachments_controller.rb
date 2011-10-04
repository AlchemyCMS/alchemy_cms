class Admin::AttachmentsController < AlchemyController

  protect_from_forgery :except => [:create]
  
  filter_access_to :all

  def index
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @attachments = Attachment.where(cond).order(:name)
    else
      @attachments = Attachment.where(cond).paginate(
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      ).order(:name)
    end
  end

  def new
    @attachment = Attachment.new
    render :layout => false
  end

  def create
    @attachment = Attachment.new(:uploaded_data => params[:Filedata])
    @attachment.name = @attachment.filename
    @attachment.save
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @attachments = Attachment.where(cond).order(:name)
    else
      @attachments = Attachment.where(cond).paginate(
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      ).order(:name)
    end
    @message = _('File %{name} uploaded succesfully') % {:name => @attachment.name}
    if params[Rails.application.config.session_options[:key]].blank?
      flash[:notice] = @message
      redirect_to :action => :index
    end
  rescue Exception => e
    log_error $!
    render :update, :status => 500 do |page|
      page.call('Alchemy.growl', _('File upload error: %{error}') % {:error => e}, :error)
    end
  end

  def edit
    @attachment = Attachment.find(params[:id])
    render :layout => false
  end

  def update
    begin
      @attachment = Attachment.find(params[:id])
      oldname = @attachment.name
      if @attachment.update_attributes(params[:attachment])
        flash[:notice] = _("File renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @attachment.name}
      else
        render :action => "edit"
      end
    rescue Exception => e
      exception_handler(e)
    end
    redirect_to admin_attachments_path(:page => params[:page], :query => params[:query], :per_page => params[:per_page])
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    name = @attachment.name
    @attachment.destroy
    render :update do |page|
      flash[:notice] = ( _("File: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to admin_attachments_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
    end
  end

  def archive_overlay
    @content = Content.find(params[:content_id])
    @options = params[:options]
    if !params[:only].blank?
      condition = "filename LIKE '%.#{params[:only].join("' OR filename LIKE '%.")}'"
    elsif !params[:except].blank?
      condition = "filename NOT LIKE '%.#{params[:except].join("' OR filename NOT LIKE '%.")}'"
    else
      condition = ""
    end
    @attachments = Attachment.where(condition).order(:name)
    render :layout => false
  end

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
