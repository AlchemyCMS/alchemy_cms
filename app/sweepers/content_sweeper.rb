class ContentSweeper < ActionController::Caching::Sweeper
  observe Element
  
  def after_update(element)
    expire_cache_for(element.contents)
  end
  
  def after_destroy(element)
    expire_cache_for(element.contents)
  end
  
private
  
  def expire_cache_for(contents)
    contents.each do |content|
      expire_fragment(content)
    end
  end
  
end
