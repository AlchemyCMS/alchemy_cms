# frozen_string_literal: true

Rails.application.routes.draw do

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)

  get '/login' => 'login#new', as: 'login'
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
