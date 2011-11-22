# This is the main Alchemy controller all other controllers inheret from.
module Alchemy
	class BaseController < ApplicationController

		include FastGettext::Translation
		include Alchemy::Modules

		protect_from_forgery

		before_filter :set_language
		before_filter :init_gettext
		before_filter :set_translation
		before_filter :mailer_set_url_options

		helper_method :current_server, :configuration, :multi_language?, :current_user

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

		def set_language_to(language_id)
			@language = Language.find(language_id)
			if @language
				session[:language_id] = @language.id
				session[:language_code] = @language.code
				I18n.locale = @language.code
			else
				logger.error "+++++++ Language not found for language_id: #{language_id}"
			end
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

	private

		def init_gettext#:nodoc:
			FastGettext.available_locales = configuration(:translations).collect { |l| l[:language_code] }
		end

		# Setting the Alchemy GUI translation to users preffered language, or to the default translation.
		# You can set the default_translation in your config/alchemy/config.yml file
		def set_translation
			if current_user.blank? || current_user.language.blank?
				FastGettext.locale = configuration(:default_translation) || I18n.locale
			else
				FastGettext.locale = current_user.language || I18n.locale
			end
		end

		# What is this? Who was this?
		def last_request_update_allowed?
			true #action_name =! "update_session_time_left"
		end

		# Do we really need this anymore?
		def set_language_from_client
			if params[:lang].blank?
				lang = request.env['HTTP_ACCEPT_LANGUAGE'][0..1] unless request.env['HTTP_ACCEPT_LANGUAGE'].blank?
				language_code = lang
			else
				language_code = params[:lang]
			end
			@language = Language.find_by_code(language_code) || Language.get_default
			if @language.blank?
				logger.warn "+++++++ Language not found for code: #{language_code}"
				render :file => Rails.root + 'public/404.html', :code => 404
			else
				session[:language_id] = @language.id
				I18n.locale = session[:language_code] = @language.code
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

	protected

		def set_language
			if params[:lang].blank? or session[:language_id].blank?
				set_language_to_default
			else
				set_language_to(session[:language_id])
			end
		end

		def permission_denied
			if current_user
				if current_user.role == 'registered'
					redirect_to root_path
				else
					if request.referer == login_url
						render :file => File.join(Rails.root.to_s, 'public', '422.html'), :status => 422, :layout => false
					elsif request.xhr?
						render :partial => 'alchemy/admin/partials/flash', :locals => {:message => _('You are not authorized'), :flash_type => 'warning'}
					else
						flash[:error] = _('You are not authorized')
						redirect_to admin_path
					end
				end
			else
				flash[:info] = _('Please log in')
				if request.xhr?
					render :action => :permission_denied
				else
					store_location
					redirect_to login_path
				end
			end
		end

		# Setting language relevant stuff to defaults.
		def set_language_to_default
			@language ||= Language.get_default
			session[:language_id] = @language.id
			I18n.locale = session[:language_code] = @language.code
		end
  
	end
end
