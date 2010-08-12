@languages ||= Alchemy::Configuration.parameter(:languages).collect{ |l| l[:language_code] }
@lang_regex ||= Regexp.new(@languages.join('|'))

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'pages', :action => 'show'
  map.login "/admin/login", :controller => "admin", :action => "login"
  map.logout "/admin/logout", :controller => "admin", :action => "logout"
  map.admin_layoutpages "/admin/pages/layoutpages", :controller => "admin/pages", :action => "layoutpages"
  map.download_attachment "/attachment/:id/download", :controller => 'attachments', :action => 'download'
  map.show_attachment "/attachment/:id/show", :controller => 'attachments', :action => 'show'
  map.namespace :admin do |admin|
    admin.resources :users
    admin.resources :contents, :collection => {:order => :post}
    admin.resources :elements, :has_many => :contents, :shallow => true, :collection => {:list => :get, :order => :post}
    admin.resources(
      :pages,
      :collection => {
        :switch_language => :get,
        :create_language => :post,
        :link => :get,
        :layoutpages => :get,
        :move => :post,
        :flush => :post
      },
      :member => {
        :publish => :post,
        :unlock => :post,
        :configure => :get,
        :preview => :get
      },
      :has_many => [:elements],
      :shallow => true
    )
    admin.resources(
      :pictures,
      :collection => {
        :archive_overlay => :get,
        :add_upload_form => :get,
        :flush => :post
      },
      :member => {
        :remove => :delete
      }
    )
    admin.resources(
      :attachments,
      :collection => {
        :archive_overlay => :get,
        :add_upload_form => :get
      },
      :member => {
        :download => :get
      }
    )
    admin.resources :essence_pictures, :member => {:crop => :get}, :except => [:show, :new, :create]
    admin.resources :essence_files
  end
  map.resources :user_sessions
  map.resources :elements, :only => :show
  map.resources :mails
  map.show_picture '/pictures/show/:id/:size/:name.:format', :controller => 'pictures', :action => 'show'
  map.zoom_picture '/pictures/zoom/:id/picture.png', :controller => 'pictures', :action => 'zoom'
  map.thumbnail '/pictures/thumbnails/:id/:size/thumbnail.png', :controller => 'pictures', :action => 'thumbnail'
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.show_language_root '/:lang', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.show_page '/:urlname.:format', :controller => 'pages', :action => 'show'
  map.show_page_with_language '/:lang/:urlname.:format', :controller => 'pages', :action => 'show', :lang => @lang_regex
  map.connect ':controller/:action/:id'
end
