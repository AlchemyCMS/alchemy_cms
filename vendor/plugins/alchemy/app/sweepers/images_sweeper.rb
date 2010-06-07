class ImagesSweeper < ActionController::Caching::Sweeper
  observe Image

  def after_save(image)
    expire_cache_for(image)
  end

  def after_destroy(image)
    expire_cache_for(image)
  end

  private

  def expire_cache_for(image)
    for format in ['jpg', 'png'] do
      expire_page(:controller => 'images', :action => 'show', :id => image, :name => image.name, :format => format)
    end
    expire_page(:controller => 'images', :action => 'show_in_window', :id => image, :format => 'jpg')
    expire_page(:controller => 'images', :action => 'thumb', :id => image, :format => 'jpg')
  end

end
