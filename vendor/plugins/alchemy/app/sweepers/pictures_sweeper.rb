class PicturesSweeper < ActionController::Caching::Sweeper
  observe Picture

  def after_save(picture)
    expire_cache_for(picture)
  end

  def after_destroy(picture)
    expire_cache_for(picture)
  end

  private

  def expire_cache_for(picture)
    for format in ['jpg', 'png'] do
      expire_page(:controller => 'pictures', :action => 'show', :id => picture, :name => picture.name, :format => format)
    end
    expire_page(:controller => 'pictures', :action => 'show_in_window', :id => picture, :format => 'jpg')
    expire_page(:controller => 'pictures', :action => 'thumb', :id => picture, :format => 'jpg')
  end

end
