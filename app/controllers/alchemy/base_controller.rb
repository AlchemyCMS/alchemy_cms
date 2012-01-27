# This is the main Alchemy controller all other controllers inheret from.
module Alchemy
	class BaseController < ApplicationController

		include Alchemy::Modules

		protect_from_forgery

		before_filter :set_language
		before_filter :mailer_set_url_options

		helper_method :current_server, :configuration, :multi_language?, :current_user, :t

		# Returns a host string with the domain the app is running on.
		def current_server
			# For local development server
			if request.port != 80
				"http://#{request.host}:#{request.port}"
			# For remote production server
			else
				"http://#{request.host}"
			end
		end

		def configuration(name)
			return Alchemy::Config.get(name)
		end

		def multi_language?
			Language.published.count > 1
		end

		def current_user
			return @current_user if defined?(@current_user)
			@current_user = current_user_session && current_user_session.record
		end

		def current_user_session
			return @current_user_session if defined?(@current_user_session)
			@current_user_session = UserSession.find
		end

		def logged_in?
			!current_user.blank?
		end

		# Overriding +I18n+s default +t+ helper, so we can pass it through +Alchemy::I18n+
		def t(key, *args)
			Alchemy::I18n.t(key, *args)
		end

	private

		# Sets the language for rendering pages in pages controller
		def set_language
			if params[:lang].blank? and session[:language_id].blank?
				set_language_to_default
			elsif !params[:lang].blank?
				set_language_from(params[:lang])
				::I18n.locale = params[:lang]
			end
		end

		def set_language_from(language_code_or_id)
			if language_code_or_id.is_a?(String) && language_code_or_id.match(/^\d+$/)
				language_code_or_id = language_code_or_id.to_i
			end
			case language_code_or_id.class.name
				when "String"
					@language = Language.find_by_code(language_code_or_id)
				when "Fixnum"
					@language = Language.find(language_code_or_id)
			end
			store_language_in_session(@language)
		end

		def set_language_to_default
			@language = Language.get_default
			if @language
				store_language_in_session(@language)
			else
				raise "No Default Language found! Did you run `rake alchemy:db:seed` task?"
			end
		end

		def store_language_in_session(language)
			if language
				session[:language_code] = language.code
				session[:language_id] = language.id
			else
				logger.warn "!!!! Language not found for #{language.inspect}. Setting to default!"
				set_language_to_default
			end
		end

		def store_location
			session[:redirect_path] = request.path
		end

		def mailer_set_url_options
			ActionMailer::Base.default_url_options[:host] = request.host_with_port
		end

		def hashified_options
			return nil if params[:options].blank?
			if params[:options].is_a?(String)
				Rack::Utils.parse_query(params[:options])
			else
				params[:options]
			end
		end

		def layout_for_page
			if !params[:layout].blank? && params[:layout] != 'none'
				params[:layout]
			elsif File.exist?(Rails.root.join('app/views/layouts', 'application.html.erb'))
				'application'
			else
				'alchemy/pages'
			end
		end

	protected

		def permission_denied
			if current_user
				if current_user.role == 'registered'
					redirect_to alchemy.root_path
				else
					if request.referer == alchemy.login_url
						render :file => File.join(Rails.root.to_s, 'public', '422.html'), :status => 422, :layout => false
					elsif request.xhr?
						render :partial => 'alchemy/admin/partials/flash', :locals => {:message => t('You are not authorized'), :flash_type => 'warning'}
					else
						flash[:error] = t('You are not authorized')
						redirect_to alchemy.admin_dashboard_path
					end
				end
			else
				flash[:info] = t('Please log in')
				if request.xhr?
					render :action => :permission_denied
				else
					store_location
					redirect_to alchemy.login_path
				end
			end
		end

	end
end
