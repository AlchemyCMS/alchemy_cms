# frozen_string_literal: true

require "alchemy/routing_constraints"

Alchemy::Engine.routes.draw do
  root to: "pages#index"

  get "/sitemap.xml", to: "pages#sitemap", format: "xml"

  scope Alchemy.admin_path, {constraints: Alchemy.admin_constraints} do
    get "/", to: redirect("#{Alchemy.admin_path}/dashboard"), as: :admin
    get "/dashboard", to: "admin/dashboard#index", as: :admin_dashboard
    get "/dashboard/info", to: "admin/dashboard#info", as: :dashboard_info
    get "/help", to: "admin/dashboard#help", as: :help
    get "/dashboard/update_check", to: "admin/dashboard#update_check", as: :update_check
    get "/leave", to: "admin/base#leave", as: :leave_admin
  end

  namespace :admin, {path: Alchemy.admin_path, constraints: Alchemy.admin_constraints} do
    resources :nodes
    resources :page_definitions, only: :index

    resources :pages do
      resources :elements
      collection do
        post :flush
        post :copy_language_tree
        get :create_language
        get :link
        get :tree
      end
      member do
        post :unlock
        post :publish
        patch :fold
        get :configure
        get :preview
        get :info
      end
    end

    resources :elements do
      collection do
        post :order
      end
      member do
        patch :publish
        post :collapse
        post :expand
      end
    end

    resources :layoutpages, only: [:index, :edit, :update]

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

    resources :picture_descriptions, only: [:index, :edit]

    resources :attachments, except: [:new] do
      member do
        put :assign
      end
    end

    concern :croppable do
      member do
        get :crop
      end
    end

    resources :ingredients, only: [:edit, :update], concerns: [:croppable]

    resources :legacy_page_urls
    resources :languages do
      collection do
        get :switch
      end
    end

    resource :clipboard, only: [], controller: "clipboard" do
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

    get "/styleguide", to: "styleguide#index"
  end

  get "/attachment/:id/download(/:name)", to: "attachments#download",
    as: :download_attachment
  get "/attachment/:id/show(/:name)", to: "attachments#show",
    as: :show_attachment

  resources :messages, only: [:index, :new, :create]

  namespace :api, defaults: {format: "json"} do
    resources :attachments, only: [:index]
    resources :ingredients, only: [:index]

    resources :elements, only: [:index, :show]

    resources :pages, only: [:index] do
      get "elements", to: "elements#index", as: "elements"
      get "elements/:named", to: "elements#index", as: "named_elements"
      collection do
        get :nested
      end
      member do
        patch :move
      end
    end

    get "/pages/*urlname(.:format)", to: "pages#show", as: "page"
    get "/admin/pages/:id(.:format)", to: "pages#show", as: "preview_page"

    resources :nodes, only: [:index] do
      member do
        patch :move
        patch :toggle_folded
      end
    end
  end

  get "/:locale", to: "pages#index",
    constraints: {locale: Alchemy::RoutingConstraints::LOCALE_REGEXP},
    as: :show_language_root

  # The page show action has to be last route
  constraints(locale: Alchemy::RoutingConstraints::LOCALE_REGEXP) do
    get "(/:locale)/*urlname(.:format)", to: "pages#show",
      constraints: Alchemy::RoutingConstraints.new,
      as: :show_page
  end
end
