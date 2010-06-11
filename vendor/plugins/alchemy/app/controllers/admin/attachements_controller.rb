class Admin::AttachementsController < ApplicationController
  
  protect_from_forgery :except => [:create]
  layout 'admin'
  
  before_filter :set_translation
  filter_access_to :all
  
  def index
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @attachements = Attachement.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @attachements = Attachement.paginate(
        :all,
        :order => :name,
        :conditions => cond,
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 20)
      )
    end
  end
  
  def new
    @attachement = Attachement.new
    render :layout => false
  end
  
  def create
    @attachement = Attachement.new(:uploaded_data => params[:Filedata])
    @attachement.name = @attachement.filename
    @attachement.save
    
    cond = "name LIKE '%#{params[:query]}%' OR filename LIKE '%#{params[:query]}%'"
    if params[:per_page] == 'all'
      @attachements = Attachement.find(
        :all,
        :order => :name,
        :conditions => cond
      )
    else
      @attachements = Attachement.paginate(
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
  
  def edit
    @attachement = Attachement.find(params[:id])
    render :layout => false
  end
  
  def update
    begin
      @attachement = Attachement.find(params[:id])
      oldname = @attachement.name
      if @attachement.update_attributes(params[:attachement])
        flash[:notice] = _("File renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @attachement.name}
      else
        render :action => "edit"
      end
    rescue
      log_error($!)
      flash[:error] = _('file_rename_error')
    end
    redirect_to admin_attachements_path(:page => params[:page], :query => params[:query], :per_page => params[:per_page])
  end
  
  def destroy
    @attachement = Attachement.find(params[:id])
    name = @attachement.name
    @attachement.destroy
    render :update do |page|
      flash[:notice] = ( _("File: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to admin_attachements_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
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
    @attachements = Attachement.all(:order => :name, :conditions => condition)
    render :layout => false
  end
  
end