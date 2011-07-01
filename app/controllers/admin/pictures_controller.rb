class Admin::PicturesController < AlchemyController
  protect_from_forgery :except => [:create]
  layout 'alchemy'
  
  before_filter :set_translation
  
  filter_access_to :all
  
  cache_sweeper :pictures_sweeper, :only => [:update, :destroy]
  
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
      @size = params[:size] || 'medium'
      @options = params[:options]
      @page = params[:page] || 1
      @per_page = pictures_per_page_for_size(@size)
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
        :per_page => (params[:per_page] || @per_page || 32)
      )
    end
    @message = _('Picture %{name} uploaded succesfully') % {:name => @picture.name}
    if params[ActionController::Base.session_options[:key].to_sym].blank?
      flash[:notice] = @message
      redirect_to :back
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def archive_overlay
    @content = Content.find_by_id(params[:content_id], :select => 'id')
    @element = Element.find_by_id(params[:element_id], :select => 'id')
    @size = params[:size] || 'medium'
    @pictures = Picture.paginate(
      :all,
      :order => :name,
      :page => params[:page] || 1,
      :per_page => pictures_per_page_for_size(@size),
      :conditions => "name LIKE '%#{params[:query]}%'"
    )
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
    @picture.name = params[:name]
    @picture.save
    render :update do |page|
      page.replace "picture_#{@picture.id}", :partial => "picture", :locals => {:picture => @picture}
      page << %(
        Alchemy.inPlaceEditor({
          save_label: "#{ _('save') }",
          cancel_label: "#{ _('cancel') }"
        });
      )
      Alchemy::Notice.show(page, ( _("Image renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @picture.name} ))
    end
  rescue Exception => e
    exception_handler(e)
  end
  
  def destroy
    @picture = Picture.find(params[:id])
    name = @picture.name
    @picture.destroy
    render :update do |page|
      flash[:notice] = ( _("Image: '%{name}' deleted successfully") % {:name => name} )
      page.redirect_to admin_pictures_path(:per_page => params[:per_page], :page => params[:page], :query => params[:query])
    end
  end
  
  def flush
    Picture.all.each do |picture|
      FileUtils.rm_rf("#{Rails.root}/public/pictures/show/#{picture.id}")
      FileUtils.rm_rf("#{Rails.root}/public/pictures/thumbnails/#{picture.id}")
      expire_page(:controller => '/pictures', :action => 'zoom', :id => picture.id)
    end
    render :update do |page|
      Alchemy::Notice.show(page, _('Picture cache flushed'))
    end
  end
  
  def show_in_window
    @picture = Picture.find(params[:id])
    render :layout => false
  end
  
private
  
  def pictures_per_page_for_size(size)
    case size
      when 'small' then per_page = 35
      when 'large' then per_page = 4
    else
      per_page = 12
    end
    return per_page
  end
  
end
