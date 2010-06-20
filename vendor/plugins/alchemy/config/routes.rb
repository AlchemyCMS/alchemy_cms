@languages ||= Alchemy::Configuration.parameter(:languages).collect{ |l| l[:language_code] }
@lang_regex ||= Regexp.new(@languages.join('|'))

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'show'
  map.login "/admin/login", :controller => "admin", :action => "login"
  map.logout "/admin/logout", :controller => "admin", :action => "logout"
  map.admin_layoutpages "/admin/pages/layoutpages", :controller => "admin/pages", :action => "layoutpages"
  map.resources :attachements, :member => {:download => :get}
  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :elements, :has_many => :contents, :shallow => true, :collection => {:list => :get}
    admin.resources(
      :pages,
      :collection => {
        :switch_language => :get,
        :create_language => :get,
        :link => :get,
        :layoutpages => :get,
        :move => :post,
      },
      :member => {
        :publish => :post,
        :unlock => :post,
        :configure => :get
      },
      :has_many => [:elements],
      :shallow => true
    )
    admin.resources(
      :images,
      :collection => {
        :archive_overlay => :get,
        :add_upload_form => :get
      },
      :member => {
        :remove => :delete
      }
    )
    admin.resources :attachements, :collection => {
      :archive_overlay => :get,
      :download => :get,
      :add_upload_form => :get
    }
    admin.resources :contents
    admin.resources :essence_pictures
    admin.resources :essence_files
  end
  map.resources :user_sessions
  map.resources :mails
  map.show_image '/images/show/:id/:size/:name.:format', :controller => 'images', :action => 'show'
  map.thumbnail '/admin/images/thumb/:id/:size/thumbnail.jpg', :controller => 'admin/images', :action => 'thumb'
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.show_language_root '/:lang', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.show_page '/:urlname', :controller => 'pages', :action => 'show'
  map.show_page_with_language '/:lang/:urlname', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.connect ':controller/:action/:id'
end
