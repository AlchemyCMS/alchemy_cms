class PicturesSweeper < ActionController::Caching::Sweeper
  observe Picture
  
  def after_update(picture)
    expire_cache_for(picture)
  end
  
  def after_destroy(picture)
    expire_cache_for(picture)
  end
  
private
  
  def expire_cache_for(picture)
    FileUtils.rm_rf("#{Rails.root}/public/pictures/show/#{picture.id}")
    FileUtils.rm_rf("#{Rails.root}/public/pictures/thumbnails/#{picture.id}")
    expire_page(:controller => '/pictures', :action => 'zoom', :id => picture.id)
  end
  
end
