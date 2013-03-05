Alchemy::Engine.routes.draw do

  root :to => 'pages#show'

  get '/admin' => redirect(
    "#{Alchemy.mount_point}/admin/dashboard"
  )

  get '/admin/dashboard' => 'admin/dashboard#index',
        :as => :admin_dashboard
  get '/admin/dashboard/info' => 'admin/dashboard#info',
        :as => :dashboard_info
  get '/admin/dashboard/update_check' => 'admin/dashboard#update_check',
        :as => :update_check

  devise_scope :user do
    get '/admin/login' => 'user_sessions#new', :as => :login
    post '/admin/login' => 'user_sessions#create', :as => :login
    delete '/admin/logout' => 'user_sessions#destroy', :as => :logout
    get '/admin/dashboard' => 'admin/dashboard#index', :as => :user_root
    get '/admin/leave' => 'user_sessions#leave', :as => :leave_admin
    get '/admin/passwords' => 'passwords#new', :as => :new_password
    get '/admin/passwords/:id/edit' => 'passwords#edit', :as => :edit_password
    post '/admin/passwords' => 'passwords#create', :as => :password
    put '/admin/passwords' => 'passwords#update', :as => :password
  end

  # This actualy does all the Devise magic. I.e. current_user method in ApplicationController
  devise_for(
    :user,
    :class_name => 'Alchemy::User',
    :controllers => {
      :sessions => 'alchemy/user_sessions'
    },
    :skip => [:sessions, :passwords] # skipping Devise default routes.
  )

  get '/admin/signup' => 'users#new', :as => :signup
  post '/admin/signup' => 'users#create', :as => :signup

  get '/attachment/:id/download(/:name)' => 'attachments#download',
        :as => :download_attachment
  get '/attachment/:id/show' => 'attachments#show',
        :as => :show_attachment

  # Legacy download urls
  get '/wa_files/download/:id' => 'attachments#download'
  get '/uploads/files/0000/:id/:name(.:suffix)' => 'attachments#download'

  # Picture urls
  get "/pictures/:id/show(/:size)(/:crop)(/:crop_from/:crop_size)(/:quality)/:name.:format" => 'pictures#show',
        :as => :show_picture
  get '/pictures/:id/zoom/:name.:format' => 'pictures#zoom',
        :as => :zoom_picture
  get "/pictures/:id/thumbnails/:size(/:crop)(/:crop_from/:crop_size)/:name.:format" => 'pictures#thumbnail',
        :as => :thumbnail, :defaults => {:format => 'png', :name => "thumbnail"}

  resources :messages, :only => [:index, :new, :create]
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
        post :copy_language_tree
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
        post :flush, :update_multiple
        delete :delete_multiple
        get :edit_multiple
      end
      member do
        get :info
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

    resources :languages

    resource :clipboard, :only => :index, :controller => 'clipboard' do
      collection do
        get :index
        delete :clear
        delete :remove
        post :insert
      end
    end

    resource :trash, :only => :index, :controller => 'trash' do
      collection do
        get :index
        delete :clear
      end
    end

    resources :tags do
      collection do
        get :autocomplete
      end
    end

    resources :sites

  end

  match '/:lang' => 'pages#show',
        :constraints => {:lang => /[a-z]{2}(-[a-z]{2})?/},
        :as => :show_language_root

  # The page show action has to be last route
  match '(/:lang)(/:level1(/:level2(/:level3)))/:urlname(.:format)' => 'pages#show',
        :constraints => {:lang => /[a-z]{2}(-[a-z]{2})?/},
        :as => :show_page

end
