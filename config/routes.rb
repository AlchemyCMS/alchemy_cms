Rails.application.routes.draw do
  
  root :to => 'pages#show'
  
  match '/admin' => 'admin#index',
    :as => :admin
  match '/admin/login' => 'admin#login',
    :as => :login
  match '/admin/logout' => 'admin#logout',
    :as => :logout
  match '/admin/pages/layoutpages' => 'admin#pages#layoutpages',
    :as => :admin_layoutpages
  match '/attachment/:id/download' => 'attachments#download',
    :as => :download_attachment
  match '/attachment/:id/show' => 'attachments#show',
    :as => :show_attachment
  match '/pictures/show/:id/:size/:crop_from/:crop_size/:name.:format' => 'pictures#show',
    :as => :show_cropped_picture
  match '/pictures/show/:id/:size/:crop/:name.:format' => 'pictures#show',
    :as => :show_picture_with_crop
  match '/pictures/show/:id/:size/:name.:format' => 'pictures#show',
    :as => :show_picture
  match '/pictures/zoom/:id/picture.png' => 'pictures#zoom',
    :as => :zoom_picture
  match '/pictures/thumbnails/:id/:size/thumbnail.png' => 'pictures#thumbnail',
    :as => :thumbnail
  match '/:lang' => 'pages#show',
    :constraints => {:lang => Regexp.new(Alchemy::Config.available_languages.join('|'))},
    :as => :show_language_root
  match '/:urlname(.:format)' => 'pages#show',
    :as => :show_page
  match '/:lang/:urlname(.:format)' => 'pages#show',
    :constraints => {:lang => Regexp.new(Alchemy::Config.available_languages.join('|'))},
    :as => :show_page_with_language
  
  resources :user_sessions
  resources :elements, :only => :show
  resources :mails
  
  namespace :admin do 
    
    resources :users
    
    resources :contents do
      collection do 
        post :order
      end
    end
    
    resources :elements do 
      resources :contents
      collection do 
        get :list
        post :order
      end
    end
    
    resources :pages do 
      collection do 
        get :switch_language
        get :create_language
        get :link
        get :layoutpages
        post :move
        post :flush
      end
      member do 
        post :publish
        post :unlock
        get :configure
        get :preview
      end
      resources :elements
    end
    
    resources :pictures do 
      collection do 
        get :archive_overlay
        get :add_upload_form
        post :flush
      end
      member do 
        delete :remove
      end
    end
    
    resources :attachments do 
      collection do 
        get :archive_overlay
        get :add_upload_form
      end
      member do 
        get :download
      end
    end
    
    resources :essence_pictures, :except => [:show, :new, :create] do 
      member do 
        get :crop
      end
    end
    
    resources :essence_files
    
  end
  
end
