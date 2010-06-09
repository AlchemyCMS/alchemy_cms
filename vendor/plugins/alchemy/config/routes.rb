@languages ||= Configuration.parameter(:languages).collect{ |l| l[:language_code] }
@lang_regex ||= Regexp.new(@languages.join('|'))

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'show'
  map.login "/admin/login", :controller => "admin", :action => "login"
  map.logout "/admin/logout", :controller => "admin", :action => "logout"
  map.layoutpages "/pages/layoutpages", :controller => "pages", :action => "layoutpages"
  map.resources :users
  map.resources :user_sessions
  map.resources :mails
  map.resources :elements, :has_many => :contents, :shallow => true, :collection => {:list => :get}
  map.resources(
    :pages,
    :collection => {
      :switch_language => :get,
      :create_language => :get,
      :layoutpages => :get,
      :order => :post,
      :sitemap => :get
    },
    :member => {
      :publish => :post,
      :unlock => :post,
      :configure => :get
    },
    :has_many => [:elements],
    :shallow => true
  )
  map.resources(
    :images,
    :collection => {
      :archive_overlay => :get,
      :add_upload_form => :get
    },
    :member => {
      :remove => :delete
    }
  )
  map.resources :attachements, :collection => {
    :archive_overlay => :get,
    :download => :get,
    :add_upload_form => :get
  }
  map.resources :contents
  map.resources :essence_pictures
  map.resources :essence_files
  map.show_image '/images/show/:id/:size/:name.:format', :controller => 'images', :action => 'show'
  map.thumbnail '/images/thumb/:id/:size/thumbnail.jpg', :controller => 'images', :action => 'thumb'
  map.download_file '/attachements/:id/download/:name', :controller => 'attachements', :action => 'download'
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.show_language_root '/:lang', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.show_page '/:urlname', :controller => 'pages', :action => 'show'
  map.show_page_with_language '/:lang/:urlname', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.connect ':controller/:action/:id'
end
