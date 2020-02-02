Alchemy::Engine.routes.draw do
  namespace :admin, {
    path: Alchemy.admin_path,
    constraints: Alchemy.admin_constraints
  } do

    devise_for :user,
      class_name: 'Alchemy::User',
      singular: :user,
      skip: :all,
      controllers: {
        sessions: 'alchemy/admin/user_sessions',
        passwords: 'alchemy/admin/passwords'
      },
      router_name: :alchemy

    devise_scope :user do
      get '/dashboard' => 'dashboard#index',
        :as => :user_root
      get '/signup' => 'users#signup',
        :as => :signup
      get '/login' => 'user_sessions#new',
        :as => :login
      post '/login' => 'user_sessions#create'
      match '/logout' => 'user_sessions#destroy',
        :as => :logout, via: Devise.sign_out_via

      get '/passwords' => 'passwords#new',
        :as => :new_password
      get '/passwords/:id/edit/:reset_password_token' => 'passwords#edit',
        :as => :edit_password
      post '/passwords' => 'passwords#create',
        :as => :reset_password
      patch '/passwords' => 'passwords#update',
        :as => :update_password
    end

    resources :users
  end
end
