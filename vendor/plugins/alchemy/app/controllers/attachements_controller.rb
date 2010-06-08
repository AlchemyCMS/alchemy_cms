class AttachementsController < ApplicationController
  
  protect_from_forgery :except => [:create]
  layout 'admin'
  
  before_filter :set_translation, :except => [:show, :download]
  filter_access_to :all, :except => [:show, :download]
  
  def index
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @files = Attachement.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @files = Attachement.paginate(
        :all,
        :order => :name,
        :conditions => cond,
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      )
    end
  end
  
  def new
    @file = Attachement.new
    render :layout => false
  end
  
  def create
    @file = Attachement.new(:uploaded_data => params[:Filedata])
    @file.name = @file.filename
    @file.save
    
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @files = Attachement.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @files = Attachement.paginate(
        :all,
        :order => :name,
        :conditions => cond,
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      )
    end
    if params[:_alchemy_session].blank?
      redirect_to :action => :index
    end
  end
  
  # sends file inline. i.e. for viewing pdfs/movies in browser
  def show
    @file = Attachement.find(params[:id])
    #render :layout => 'false'
    send_file(
      "#{RAILS_ROOT}/public" + @file.public_filename, {
        :name => @file.filename,
        :type => @file.content_type,
        :disposition => 'inline'
      }
    )
  end
  
  # sends file as attachment. aka download
  def download
    @file = Attachement.find(params[:id])
    send_file(
      @file.full_filename, {
        :name => @file.filename,
        :type => @file.content_type,
        :disposition => 'attachment'
      }
    )
  end
  
  def edit
    @file = Attachement.find(params[:id])
    render :layout => false
  end
  
  def update
    begin
      @file = Attachement.find(params[:id])
      oldname = @file.name
      if @file.update_attributes(params[:file])
        flash[:notice] = _("File renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @file.name}
      else
        render :action => "edit"
      end
    rescue
      log_error($!)
      flash[:error] = _('file_rename_error')
    end
    redirect_to attachements_path(:page => params[:page], :query => params[:query], :per_page => params[:per_page])
  end
  
  def destroy
    @file = Attachement.find(params[:id])
    name = @file.name
    @file.destroy
    render :update do |page|
      flash[:notice] = ( _("File: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to attachements_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
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
    @files = Attachement.all(:order => :name, :conditions => condition)
    render :layout => false
  end
  
end