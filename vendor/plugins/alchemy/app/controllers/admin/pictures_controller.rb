class Admin::PicturesController < ApplicationController
  
  protect_from_forgery :except => [:create]
  layout 'admin'
  
  before_filter :set_translation, :except => [:thumb]
  
  filter_access_to :all
  
  caches_page :show_in_window, :thumb
  cache_sweeper :images_sweeper, :only => [:update]
  
  def index
    if params[:per_page] == 'all'
      @pictures = Picture.find(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'"
      )
    else
      @pictures = Picture.paginate(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'",
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 32)
      )
    end
  end
  
  def new
    @picture = Picture.new
    @while_assigning = params[:while_assigning] == 'true'
    if @while_assigning
      @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
      @element = Element.find(params[:element_id], :select => 'id')
      @size = params[:size]
      @options = params[:options]
      @page = params[:page]
      @per_page = params[:per_page]
    end
    render :layout => false
  end
  
  def create
    @picture = Picture.new(:image_file => params[:Filedata])
    @picture.name = @picture.image_filename
    @picture.save
    @while_assigning = params[:while_assigning] == 'true'
    if @while_assigning
      @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
      @element = Element.find(params[:element_id], :select => 'id')
      @size = params[:size]
      @options = params[:options]
      @page = params[:page]
      @per_page = params[:per_page]
    end
    
    if params[:per_page] == 'all'
      @pictures = Picture.find(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'"
      )
    else
      @pictures = Picture.paginate(
        :all,
        :order => :name,
        :conditions => "name LIKE '%#{params[:query]}%'",
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || 32)
      )
    end
    if params[:_alchemy_session].blank?
      redirect_to :back
    end
  end
  
  def archive_overlay
    @content = Content.find_by_id(params[:content_id], :select => 'id')
    @element = Element.find_by_id(params[:element_id], :select => 'id')
    @pictures = Picture.paginate(
      :all,
      :order => :name,
      :page => params[:page] || 1,
      :per_page => 32,
      :conditions => "name LIKE '%#{params[:query]}%'"
    )
    @swap = params[:swap]
    @size = params[:size] || 'small'
    @options = params[:options]
    if params[:remote] == 'true'
      render :update do |page|
        page.replace_html 'alchemy_window_body', :partial => 'archive_overlay_images'
      end
    else
      render :layout => false
    end
  end
  
  def update
    @picture = Picture.find(params[:id])
    oldname = @picture.name
    @picture.name = params[:value]
    if @picture.save
      render :update do |page|
        page.replace "image_#{@picture.id}", :partial => "image", :locals => {:image => @picture}
        Alchemy::Notice.show_via_ajax(page, ( _("Image renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @picture.name} ))
      end
    end
  end
  
  def destroy
    @picture = Picture.find(params[:id])
    name = @picture.name
    @picture.destroy
    render :update do |page|
      flash[:notice] = ( _("Image: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to admin_images_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
    end
  end
  
  def thumb
    @picture = Picture.find(params[:id])
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
    @picture = Picture.find(params[:id])
    render :layout => "image_in_window"
  end
  
end
