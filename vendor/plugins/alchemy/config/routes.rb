@languages ||= WaConfigure.parameter(:languages).collect{ |l| l[:language_code] }
@lang_regex ||= Regexp.new(@languages.join('|'))

ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'wa_pages', :action => 'show'
  map.login "/admin/login", :controller => "admin", :action => "login"
  map.logout "/admin/logout", :controller => "admin", :action => "logout"
  map.systempages "/wa_pages/systempages", :controller => "wa_pages", :action => "systempages"
  map.resources :wa_users
  map.resources :wa_user_sessions
  map.resources :wa_mails
  map.resources(
    :wa_pages,
    :collection => {
      :switch_language => :get,
      :create_language => :get,
      :systempages => :get,
      :order => :post,
      :sitemap => :get
    },
    :member => {
      :publish => :post,
      :unlock => :post,
      :edit_content => :get
    },
    :has_many => [:wa_molecules],
    :shallow => true
  )
  map.resources(
    :wa_images,
    :collection => {
      :archive_overlay => :get,
      :add_upload_form => :get
    },
    :member => {
      :remove => :delete
    }
  )
  map.resources :wa_files, :collection => {
    :archive_overlay => :get,
    :download => :get,
    :add_upload_form => :get
  }
  map.resources :wa_atoms
  map.resources :wa_atom_pictures
  map.resources :wa_atom_files
  map.resources :wa_molecules, :has_many => :wa_atoms, :shallow => true
  map.show_image '/wa_images/show/:id/:size/:name.:format', :controller => 'wa_images', :action => 'show'
  map.thumbnail '/wa_images/thumb/:id/:size/thumbnail.jpg', :controller => 'wa_images', :action => 'thumb'
  map.download_file '/wa_files/:id/download/:name', :controller => 'wa_files', :action => 'download'
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.show_language_root '/:lang', :controller => 'wa_pages', :action => 'show', :lang => @lang_regex
  map.show_page '/:urlname', :controller => 'wa_pages', :action => 'show'
  map.show_page_with_language '/:lang/:urlname', :controller => 'wa_pages', :action => 'show', :lang => @lang_regex
  map.connect ':controller/:action/:id'
end
