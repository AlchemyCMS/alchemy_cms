class Admin::PicturesController < AlchemyController
  protect_from_forgery :except => [:create]
  
  before_filter :set_translation

  filter_access_to :all

  cache_sweeper :pictures_sweeper, :only => [:update, :destroy]

  def index
    if in_overlay?
      archive_overlay
    else
      if params[:per_page] == 'all'
        @pictures = Picture.where("name LIKE '%#{params[:query]}%'").order(:name)
      else
        @pictures = Picture.where("name LIKE '%#{params[:query]}%'").paginate(
          :page => params[:page] || 1,
          :per_page => params[:per_page] || 32
        ).order(:name)
      end
    end
  end

  def new
    @picture = Picture.new
    @while_assigning = params[:while_assigning] == 'true'
    if @while_assigning
      @content = Content.find(params[:content_id], :select => 'id') if !params[:content_id].blank?
      @element = Element.find(params[:element_id], :select => 'id')
      @size = params[:size]
      @options = hashified_options
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
      @options = hashified_options
      @page = params[:page] || 1
      @per_page = pictures_per_page_for_size(@size)
    end
    if params[:per_page] == 'all'
      @pictures = Picture.where("name LIKE '%#{params[:query]}%'").order(:name)
    else
      @pictures = Picture.where("name LIKE '%#{params[:query]}%'").paginate(
        :page => (params[:page] || 1),
        :per_page => (params[:per_page] || @per_page || 32)
      ).order(:name)
    end
    @message = _('Picture %{name} uploaded succesfully') % {:name => @picture.name}
    # Are we using the Flash uploader? Or the plain html file uploader?
    if params[Rails.application.config.session_options[:key]].blank?
      flash[:notice] = @message
      redirect_to :back
    end
  rescue Exception => e
    exception_handler(e)
  end

  def update
    @picture = Picture.find(params[:id])
    oldname = @picture.name
    @picture.name = params[:name]
    @picture.save
    @message = _("Image renamed successfully from: '%{from}' to '%{to}'") % {:from => oldname, :to => @picture.name}
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
      page.call('Alchemy.growl', _('Picture cache flushed'))
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

  def hashified_options
    return nil if params[:options].blank?
    if params[:options].is_a?(String)
      Rack::Utils.parse_query(params[:options])
    else
      params[:options]
    end
  end

  def in_overlay?
    !params[:element_id].blank?
  end

  def archive_overlay
    @content = Content.find_by_id(params[:content_id], :select => 'id')
    @element = Element.find_by_id(params[:element_id], :select => 'id')
    @size = params[:size] || 'medium'
    @pictures = Picture.where("name LIKE '%#{params[:query]}%'").paginate(
      :page => params[:page] || 1,
      :per_page => pictures_per_page_for_size(@size)
    ).order(:name)
    @options = hashified_options
    respond_to do |format|
      format.html {
        render :action => 'archive_overlay', :layout => false
      }
      format.js {
        render :update do |page|
          page << "jQuery('#alchemy_window_body').html('#{escape_javascript(render(:partial => 'archive_overlay_images'))}')"
        end
      }
    end
  end

end
