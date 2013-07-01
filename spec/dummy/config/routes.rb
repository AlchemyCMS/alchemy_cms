Rails.application.routes.draw do

  get '/404' => 'errors#status_404', :as => :status_404

  namespace :admin do
    resources :events
  end

  mount Alchemy::Engine => "/"

end
