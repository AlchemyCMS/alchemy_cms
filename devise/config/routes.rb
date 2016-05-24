Alchemy::Engine.routes.draw do
  devise_for :user,
    class_name: 'Alchemy::User',
    controllers: {
      sessions: 'alchemy/user_sessions'
    },
    skip: [:sessions, :passwords]

  scope Alchemy.admin_path, {constraints: Alchemy.admin_constraints} do
    devise_scope :user do
      get '/dashboard' => 'admin/dashboard#index',
        :as => :user_root
      get '/signup' => 'admin/users#signup',
        :as => :admin_signup
      get '/login' => 'user_sessions#new',
        :as => :login
      post '/login' => 'user_sessions#create'
      delete '/logout' => 'user_sessions#destroy',
        :as => :logout

      get '/passwords' => 'passwords#new',
        :as => :new_password
      get '/passwords/:id/edit/:reset_password_token' => 'passwords#edit',
        :as => :edit_password
      post '/passwords' => 'passwords#create',
        :as => :reset_password
      patch '/passwords' => 'passwords#update',
        :as => :update_password
    end
  end

  namespace :admin, {path: Alchemy.admin_path, constraints: Alchemy.admin_constraints} do
    resources :users
  end
end
