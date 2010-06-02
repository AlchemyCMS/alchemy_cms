class WaImagesController < ApplicationController
  
  protect_from_forgery :except => [:create]
  layout 'alchemy'
  
  before_filter :set_translation, :except => [:show, :thumb]
  
  filter_access_to :all, :except => [:show]
  
  caches_page :show, :show_in_window, :thumb
  cache_sweeper :wa_images_sweeper, :only => [:update]
  
  def index
    if params[:per_page] == 'all'
      @wa_images = WaImage.find(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'"
      )
    else
      @wa_images = WaImage.paginate(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'",
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 32)
      )
    end
  end
  
  def new
    @wa_image = WaImage.new
    render :layout => false
  end
  
  def create
    @wa_image = WaImage.new(:image_file => params[:Filedata])
    @wa_image.name = @wa_image.image_filename
    @wa_image.save
    
    if params[:per_page] == 'all'
      @wa_images = WaImage.find(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'"
      )
    else
      @wa_images = WaImage.paginate(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'",
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 32)
      )
    end
    if params[:_alchemy_session].blank?
      redirect_to :action => :index
    end
  end
  
  def add_upload_form
    @wa_image = WaImage.new
    render :update do |page|
      page.insert_html :bottom, 'input_fields', :partial => 'upload_form', :locals => {:delete_button => true}
      page << "wa_overlay.updateHeight()"
    end
  end

  def archive_overlay
    @wa_molecule = WaMolecule.find_by_id(params[:wa_molecule_id])
    @images = WaImage.paginate(
      :all,
      :order => :name,
      :page => params[:page] || 1,
      :per_page => 32,
      :conditions => "name LIKE '%#{params[:query]}%'"
    )
    @wa_atom = WaAtom.find_by_id(params[:wa_atom_id])
    @swap = params[:swap]
    @size = params[:size] || 'small'
    @options = params[:options]
    if params[:remote] == 'true'
      render :update do |page|
        page.replace_html 'wa_window_body', :partial => 'archive_overlay_images'        
      end
    else
      render :layout => false      
    end
  end

  def update
    @image = WaImage.find(params[:id])
    oldname = @image.name
    @image.name = params[:value]
    if @image.save
      render :update do |page|
        page.replace "wa_image_#{@image.id}", :partial => "wa_images/image", :locals => {:image => @image}
        WaNotice.show_via_ajax(page, ( _("Image renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @image.name} ))
      end
    end
  end
  
  def destroy
    @wa_image = WaImage.find(params[:id])
    name = @wa_image.name
    @wa_image.destroy
    render :update do |page|
      flash[:notice] = ( _("Image: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to wa_images_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
    end
  end
  
  def show
    @image = WaImage.find(params[:id])
    @size = params[:size]
    @crop = !params[:crop].nil?
    @padding = params[:padding]
    @upsample = !params[:upsample].nil? ? true : false
    @options = params[:options]
    respond_to do |format|
      format.jpg
      format.png
    end
  end

  def thumb
    @image = WaImage.find(params[:id])
    case params[:size]
    when "small"
      then
      @size = "80x60"
    when "medium"
      then
      @size = "160x120"
    when "large"
      then
      @size = "240x180"
    else
      @size = "111x93"
    end
    @crop = true
    respond_to do |format|
      format.jpg
    end
  end

  def show_in_window
    @image = WaImage.find(params[:id])
    render :layout => "image_in_window"
  end
  
end
