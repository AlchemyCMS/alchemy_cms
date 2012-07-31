Alchemy::Engine.routes.draw do

  root :to => 'pages#show'

  match '/admin' => redirect(
    "#{Alchemy.mount_point}/admin/dashboard"
  )
  match '/admin/login' => 'user_sessions#login',
        :as => :login
  match '/admin/signup' => 'user_sessions#signup',
        :as => :signup
  match '/admin/leave' => 'user_sessions#leave',
        :as => :leave_admin
  match '/admin/logout' => 'user_sessions#logout',
        :as => :logout
  match '/admin/dashboard' => 'admin/dashboard#index',
        :as => :admin_dashboard

  match '/attachment/:id/download(/:name)(.:format)' => 'attachments#download',
        :as => :download_attachment

  # catching legacy download urls
  match '/wa_files/download/:id' => 'attachments#download'
  match '/uploads/files/0000/:id/:name(.:suffix)' => 'attachments#download'

  match '/attachment/:id/show' => 'attachments#show',
        :as => :show_attachment

  match "/pictures/:id/show(/:size)(/:crop)(/:crop_from/:crop_size)/:name.:format" => 'pictures#show',
        :as => :show_picture
  match '/pictures/:id/zoom/:name.:format' => 'pictures#zoom',
        :as => :zoom_picture
  match "/pictures/:id/thumbnails/:size(/:crop)(/:crop_from/:crop_size)/:name.:format" => 'pictures#thumbnail',
        :as => :thumbnail, :defaults => {:format => 'png', :name => "thumbnail"}

  resources :messages, :only => [:index, :new, :create]

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

  match '/:lang' => 'pages#show',
        :constraints => {:lang => /[a-z]{2}(-[a-z]{2})?/},
        :as => :show_language_root

  # The page show action has to be last route
  match '(/:lang)(/:level1(/:level2(/:level3)))/:urlname(.:format)' => 'pages#show',
        :constraints => {:lang => /[a-z]{2}(-[a-z]{2})?/},
        :as => :show_page

end
