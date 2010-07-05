ActionController::Routing::Routes.draw do |map|

  map.resources :contents
  map.search 'search', :controller => 'searches', :action => 'search'


  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
