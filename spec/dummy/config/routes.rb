Rails.application.routes.draw do

	namespace :admin do
		resources :events
	end

	mount Alchemy::Engine => "/alchemy"

end
