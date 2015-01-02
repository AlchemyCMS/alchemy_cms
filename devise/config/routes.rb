Alchemy::Engine.routes.draw do
  devise_for :user,
    class_name: 'Alchemy::User',
    controllers: {
      sessions: 'alchemy/user_sessions'
    },
    skip: [:sessions, :passwords]

  devise_scope :user do
    get '/admin/dashboard' => 'admin/dashboard#index',
      :as => :user_root
    get '/admin/signup' => 'admin/users#signup',
      :as => :admin_signup
    get '/admin/login' => 'user_sessions#new',
      :as => :login
    post '/admin/login' => 'user_sessions#create'
    delete '/admin/logout' => 'user_sessions#destroy',
      :as => :logout

    get '/admin/passwords' => 'passwords#new',
      :as => :new_password
    get '/admin/passwords/:id/edit/:reset_password_token' => 'passwords#edit',
      :as => :edit_password
    post '/admin/passwords' => 'passwords#create',
      :as => :reset_password
    patch '/admin/passwords' => 'passwords#update',
      :as => :update_password
  end

  namespace :admin do
    resources :users
  end
end
