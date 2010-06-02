ActionController::Routing::Routes.draw do |map|

  map.tinymce_hammer_js '/javascripts/tinymce_hammer.js', 
    :controller => 'tinymce/hammer',
    :action => 'combine'

end
