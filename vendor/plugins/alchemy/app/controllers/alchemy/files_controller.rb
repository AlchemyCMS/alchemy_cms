class Alchemy::FilesController < ApplicationController
  
  protect_from_forgery :except => [:create]
  layout 'admin'
  
  before_filter :set_translation, :except => [:show, :download]
  filter_access_to :all, :except => [:show, :download]
  
  def index
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @wa_files = File.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @wa_files = File.paginate(
        :all,
        :order => :name,
        :conditions => cond,
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      )
    end
  end
  
  def new
    @wa_file = File.new
    render :layout => false
  end
  
  def create
    @wa_file = File.new(:uploaded_data => params[:Filedata])
    @wa_file.name = @wa_file.filename
    @wa_file.save
    
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @wa_files = File.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @wa_files = File.paginate(
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
  
  # sends wa_file inline. i.e. for viewing pdfs/movies in browser
  def show
    @wa_file = File.find(params[:id])
    #render :layout => 'false'
    send_file(
      "#{RAILS_ROOT}/public" + @wa_file.public_filename, {
        :name => @wa_file.filename,
        :type => @wa_file.content_type,
        :disposition => 'inline'
      }
    )
  end
  
  # sends wa_file as attachment. aka download
  def download
    @wa_file = File.find(params[:id])
    send_file(
      @wa_file.full_filename, {
        :name => @wa_file.filename,
        :type => @wa_file.content_type,
        :disposition => 'attachment'
      }
    )
  end
  
  def edit
    @wa_file = File.find(params[:id])
    render :layout => false
  end
  
  def update
    begin
      @wa_file = File.find(params[:id])
      oldname = @wa_file.name
      if @wa_file.update_attributes(params[:wa_file])
        flash[:notice] = _("File renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @wa_file.name}
      else
        render :action => "edit"
      end
    rescue
      log_error($!)
      flash[:error] = _('file_rename_error')
    end
    redirect_to wa_files_path(:page => params[:page], :query => params[:query], :per_page => params[:per_page])
  end
  
  def destroy
    @wa_file = File.find(params[:id])
    name = @wa_file.name
    @wa_file.destroy
    render :update do |page|
      flash[:notice] = ( _("File: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to wa_files_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
    end
  end
  
  def archive_overlay
    @wa_atom = WaAtom.find(params[:wa_atom_id])
    @options = params[:options]
    if !params[:only].blank?
      condition = "filename LIKE '%.#{params[:only].join("' OR filename LIKE '%.")}'"
    elsif !params[:except].blank?
      condition = "filename NOT LIKE '%.#{params[:except].join("' OR filename NOT LIKE '%.")}'"
    else
      condition = ""
    end
    @files = File.all(:order => :name, :conditions => condition)
    render :layout => false
  end
  
end