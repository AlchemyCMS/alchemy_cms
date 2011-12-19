Rails.application.routes.draw do
  
  root :to => 'pages#show'
  
  resources :messages, :only => [:index, :new, :create]
  
  match '/admin' => 'admin#index',
    :as => :admin
  match '/admin/login' => 'admin#login',
    :as => :login
  match '/admin/signup' => 'admin#signup',
    :as => :signup
  match '/admin/leave' => 'admin#leave',
    :as => :leave_admin
  match '/admin/logout' => 'admin#logout',
    :as => :logout
  match '/attachment/:id/download(/:name)(.:format)' => 'attachments#download',
    :as => :download_attachment
  match '/attachment/:id/show' => 'attachments#show',
    :as => :show_attachment
  match '/pictures/show/:id/:size/:crop_from/:crop_size/:name.:format' => 'pictures#show',
    :as => :show_cropped_picture
  match '/pictures/show/:id/:size/:crop/:name.:format' => 'pictures#show',
    :as => :show_picture_with_crop
  match '/pictures/show/:id/:size/:name.:format' => 'pictures#show',
    :as => :show_picture
  match '/pictures/zoom/:id/picture.:format' => 'pictures#zoom',
    :as => :zoom_picture
  match  '/pictures/thumbnails/:id/:size(/:crop_from)(/:crop_size)/thumbnail.png' => 'pictures#thumbnail',
    :as => :thumbnail, :defaults => { :format => 'png' }
  match '/:lang' => 'pages#show',
    :constraints => {:lang => /[a-z]{2}/},
    :as => :show_language_root
  match '(/:lang)/:urlname(.:format)' => 'pages#show',
    :constraints => {:lang => /[a-z]{2}/},
    :as => :show_page
  match '/wa_files/download/:id' => 'attachments#download'
  match '/uploads/files/0000/:id/:name(.:suffix)' => 'attachments#download'

  resources :user_sessions
  resources :elements, :only => :show

  namespace :admin do 
  
    resources :users
    
    resources :contents do
      collection do 
        post :order
      end
    end
    
    resources :pages do 
      resources :elements
      collection do 
        post :order
        post :flush
        post :copy_language
        get :switch_language
        get :create_language
        get :link
        get :sort
      end
      member do 
        post :unlock
        post :publish
        post :fold
        post :visit
        get :configure
        get :preview
      end
    end
    
    resources :elements do 
      resources :contents
      collection do 
        get :list
        post :order
      end
      member do
        post :fold
        delete :trash
      end
    end
    
    resources :layoutpages, :only => :index
    
    resources :pictures do 
      collection do 
        post :flush
      end
      member do 
        get :show_in_window
        delete :remove
      end
    end
    
    resources :attachments do 
      member do 
        get :download
      end
    end
    
    resources :essence_pictures, :except => [:show, :new, :create] do 
      collection do
        put :assign
      end
      member do 
        get :crop
      end
    end
    
    resources :essence_files, :only => [:edit, :update] do
      collection do
        put :assign
      end
    end
    
    resources :essence_videos
    
    resources :languages
    
    # OHOHOH lovely Rails! Why, oh why I always have to hack thou?
    resource :clipboard, :only => :index, :controller => 'clipboard' do
      collection do
        get :index
        delete :clear
        delete :remove
        post :insert
      end
    end
    
    # OHOHOH lovely Rails! Why, oh why I always have to hack thou?
    resource :trash, :only => :index, :controller => 'trash' do
      collection do
        get :index
        delete :clear
      end
    end
    
  end
  
end
