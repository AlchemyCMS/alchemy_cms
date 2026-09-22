# frozen_string_literal: true

Rails.application.routes.draw do
  get "/login" => "login#new", :as => "login"
  get "/csp_opt_in" => "csp_opt_in#index"

  namespace :ns do
    resources :locations, only: :index
  end

  namespace :admin do
    resources :events
    resources :locations
    resources :series
    resources :bookings
  end

  mount Alchemy::Engine => "/"
end
