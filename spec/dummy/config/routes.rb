Rails.application.routes.draw do

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  get '/login' => 'login#new', as: 'login'

  namespace :admin do
    resources :events
  end

  mount Alchemy::Engine => "/"
end
