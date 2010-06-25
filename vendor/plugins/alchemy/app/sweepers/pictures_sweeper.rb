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
    system("rm -rf #{Rails.root}/public/pictures/show/#{picture.id}")
    system("rm -rf #{Rails.root}/public/pictures/thumbnails/#{picture.id}")
    system("rm -rf #{Rails.root}/public/pictures/zoom/#{picture.id}")
  end
  
end
