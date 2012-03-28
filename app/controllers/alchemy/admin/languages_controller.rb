module Alchemy
	module Admin
		class LanguagesController < Alchemy::Admin::ResourcesController

			def new
				@language = Alchemy::Language.new
				default_page_layout = Alchemy::Config.get(:default_language).try('[]', 'page_layout')
				@language.page_layout = default_page_layout if default_page_layout.present?
				render :layout => !request.xhr?
			end

		end
	end
end
