require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')

module Alchemy
	class Engine < Rails::Engine

		isolate_namespace Alchemy

		engine_name 'alchemy'

		# Enabling assets precompiling
		initializer 'alchemy.assets', :group => :assets do |app|
			app.config.assets.precompile += [
				"alchemy/alchemy.js",
				"alchemy/preview.js",
				"alchemy/alchemy.css",
				"alchemy/print.css",
				"alchemy/tinymce_content.css",
				"alchemy/tinymce_dialog.css",
				"tiny_mce/*"
			]
		end

		initializer 'alchemy.flash_cookie' do |config|
			config.middleware.insert_after(
				'ActionDispatch::Cookies',
				Alchemy::Middleware::FlashSessionCookie,
				::Rails.configuration.session_options[:key]
			)
		end

		# filter sensitive information during logging
		initializer "alchemy.params.filter" do |app|
			app.config.filter_parameters += [:password, :password_confirmation]
		end

	end
end
