# frozen_string_literal: true
require "alchemy/routing_constraints"

Alchemy::Engine.routes.draw do
  root to: "pages#index"

  get "/sitemap.xml" => "pages#sitemap", format: "xml"

  scope Alchemy.admin_path, { constraints: Alchemy.admin_constraints } do
    get "/" => redirect("#{Alchemy.admin_path}/dashboard"), as: :admin
    get "/dashboard" => "admin/dashboard#index", as: :admin_dashboard
    get "/dashboard/info" => "admin/dashboard#info", as: :dashboard_info
    get "/help" => "admin/dashboard#help", as: :help
    get "/dashboard/update_check" => "admin/dashboard#update_check", as: :update_check
    get "/leave" => "admin/base#leave", as: :leave_admin
  end

  namespace :admin, { path: Alchemy.admin_path, constraints: Alchemy.admin_constraints } do
    resources :contents, only: [:create]

    resources :nodes

    resources :pages do
      resources :elements
      collection do
        post :order
        post :flush
        post :copy_language_tree
        get :create_language
        get :link
        get :sort
        get :tree
      end
      member do
        post :unlock
        post :publish
        post :fold
        get :configure
        get :preview
        get :info
      end
    end

    resources :elements do
      resources :contents
      collection do
        post :order
      end
      member do
        patch :publish
        post :fold
      end
    end

    resources :layoutpages, only: [:index, :edit]

    resources :pictures, except: [:new] do
      collection do
        post :update_multiple
        delete :delete_multiple
        get :edit_multiple
      end
      member do
        get :url
        put :assign
        delete :remove
      end
    end

    resources :attachments, except: [:new] do
      member do
        get :download
        put :assign
      end
    end

    resources :essence_audios, only: [:edit, :update]

    concern :croppable do
      member do
        get :crop
      end
    end

    resources :essence_pictures, only: [:edit, :update], concerns: [:croppable]

    resources :essence_files, only: [:edit, :update]

    resources :essence_videos, only: [:edit, :update]

    resources :ingredients, only: [:edit, :update], concerns: [:croppable]

    resources :legacy_page_urls
    resources :languages do
      collection do
        get :switch
      end
    end

    resource :clipboard, only: :index, controller: "clipboard" do
      collection do
        get :index
        delete :clear
        delete :remove
        post :insert
      end
    end

    resources :tags do
      collection do
        get :autocomplete
      end
    end

    resources :sites

    get "/styleguide" => "styleguide#index"
  end

  get "/attachment/:id/download(/:name)" => "attachments#download",
      as: :download_attachment
  get "/attachment/:id/show(/:name)" => "attachments#show",
      as: :show_attachment

  resources :messages, only: [:index, :new, :create]
  resources :elements, only: :show
  resources :contents, only: :show

  namespace :api, defaults: { format: "json" } do
    resources :contents, only: [:index, :show]

    resources :elements, only: [:index, :show] do
      get "/contents" => "contents#index", as: "contents"
      get "/contents/:name" => "contents#show", as: "content"
    end

    resources :pages, only: [:index] do
      get "elements" => "elements#index", as: "elements"
      get "elements/:named" => "elements#index", as: "named_elements"
      collection do
        get :nested
      end
    end

    get "/pages/*urlname(.:format)" => "pages#show", as: "page"
    get "/admin/pages/:id(.:format)" => "pages#show", as: "preview_page"

    resources :nodes, only: [:index] do
      member do
        patch :move
        patch :toggle_folded
      end
    end
  end

  get "/:locale" => "pages#index",
    constraints: { locale: Alchemy::RoutingConstraints::LOCALE_REGEXP },
    as: :show_language_root

  # The page show action has to be last route
  constraints(locale: Alchemy::RoutingConstraints::LOCALE_REGEXP) do
    get "(/:locale)/*urlname(.:format)" => "pages#show",
      constraints: Alchemy::RoutingConstraints.new,
      as: :show_page
  end
end
