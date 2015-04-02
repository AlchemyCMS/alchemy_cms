require 'alchemy/routing_constraints'

Alchemy::Engine.routes.draw do
  root :to => 'pages#show'

  get '/sitemap.xml' => 'pages#sitemap', format: 'xml'

  get '/admin' => redirect('admin/dashboard')
  get '/admin/dashboard' => 'admin/dashboard#index',
        :as => :admin_dashboard
  get '/admin/dashboard/info' => 'admin/dashboard#info',
        :as => :dashboard_info
  get '/admin/help' => 'admin/dashboard#help',
        :as => :help
  get '/admin/dashboard/update_check' => 'admin/dashboard#update_check',
        :as => :update_check

  get '/attachment/:id/download(/:name)' => 'attachments#download',
        :as => :download_attachment
  get '/attachment/:id/show' => 'attachments#show',
        :as => :show_attachment

  # Picture urls
  get "/pictures/:id/show(/:size)(/:crop)(/:crop_from/:crop_size)(/:quality)/:name.:format" => 'pictures#show',
        :as => :show_picture
  get '/pictures/:id/zoom/:name.:format' => 'pictures#zoom',
        :as => :zoom_picture
  get "/pictures/:id/thumbnails(/:size)(/:crop)(/:crop_from/:crop_size)/:name.:format" => 'pictures#thumbnail',
        :as => :thumbnail, :defaults => {:format => 'png', :name => "thumbnail"}

  get '/admin/leave' => 'admin/base#leave', :as => :leave_admin

  resources :messages, :only => [:index, :new, :create]
  resources :elements, :only => :show

  namespace :api, defaults: {format: 'json'} do
    resources :contents, only: [:index, :show]

    resources :elements, only: [:index, :show] do
      get '/contents' => 'contents#index', as: 'contents'
      get '/contents/:name' => 'contents#show', as: 'content'
    end

    resources :pages, only: [:index] do
      get 'elements' => 'elements#index', as: 'elements'
      get 'elements/:named' => 'elements#index', as: 'named_elements'
    end

    get '/pages/*urlname(.:format)' => 'pages#show', as: 'page'
    get '/admin/pages/:id(.:format)' => 'pages#show', as: 'preview_page'
  end

  namespace :admin do
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
        get :info
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

    resources :layoutpages, :only => [:index, :edit]

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

    resources :legacy_page_urls
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

  get '/:locale' => 'pages#show',
    constraints: {locale: Alchemy::RoutingConstraints::LOCALE_REGEXP},
    as: :show_language_root

  # The page show action has to be last route
  constraints(locale: Alchemy::RoutingConstraints::LOCALE_REGEXP) do
    get '(/:locale)/*urlname(.:format)' => 'pages#show',
      constraints: Alchemy::RoutingConstraints.new,
      as: :show_page
  end
end
