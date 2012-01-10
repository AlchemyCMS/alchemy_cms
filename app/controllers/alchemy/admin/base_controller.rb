module Alchemy
	module Admin
		class BaseController < Alchemy::BaseController

			include Userstamp

			before_filter :set_translation

			helper_method :clipboard_empty?, :trash_empty?, :get_clipboard, :is_admin?

			filter_access_to :all

			rescue_from Exception, :with => :exception_handler

			layout 'alchemy/admin'

		private

			# Setting the Alchemy GUI translation to users preffered language, or taking default translation.
			# You can set the default translation in your +config/application.rb+ file
			def set_translation
				if current_user && current_user.language
					::I18n.locale = current_user.language
				end
			end

			# Handles exceptions
			def exception_handler(e)
				exception_logger(e)
				show_error_notice(e)
			end

			# Logs the current exception to the error log.
			def exception_logger(e)
				message = "\n+++++++++ Error: #{e} +++++++++++++\n\n"
				e.backtrace.each do |line|
					message += "#{line}\n"
				end
				logger.error(message)
			end

			# Displays an error notice in the Alchemy backend.
			def show_error_notice(e)
				@notice = "Error: #{e}"
				@trace = e.backtrace
				if request.xhr?
					render :action => "error_notice"
				else
					flash.now[:error] = @notice
					render '500', :status => 500
				end
			end

			def redirect_back_or_to_default(default_path = admin_dashboard_path)
				if request.env["HTTP_REFERER"].blank?
					redirect_to default_path
				else
					redirect_to :back
				end
			end

			def get_clipboard(category = nil)
				clipboard = (session[:clipboard] ||= {})
				clipboard[category.to_s.pluralize] ||= [] if category
			end

			def clipboard_empty?(category = nil)
				return true if session[:clipboard].blank?
				if category
					session[:clipboard][category.pluralize].blank?
				else
					false
				end
			end

			def trash_empty?(category)
				"alchemy/#{category.singularize}".classify.constantize.trashed.blank?
			end

			def set_stamper
				User.stamper = self.current_user
			end

			def reset_stamper
				User.reset_stamper
			end

			# Returns true if the current_user (The logged-in Alchemy User) has the admin role.
			def is_admin?
				return false if !current_user
				current_user.admin?
			end

			def render_errors_or_redirect(object, redirect_url, flash_notice, button = nil)
				if object.errors.empty?
					@redirect_url = redirect_url
					flash[:notice] = t(flash_notice)
					render :action => :redirect
				else
					render_remote_errors(object, button)
				end
			end

			def render_remote_errors(object, button = nil)
				@button = button
				@errors = ("<ul>" + object.errors.full_messages.map { |e| "<li>#{e}</li>" }.join + "</ul>").html_safe
				render :action => :remote_errors
			end

			def per_page_value_for_screen_size
				return 25 if session[:screen_size].blank?
				screen_height = session[:screen_size].split('x').last.to_i
				(screen_height / 30) - 12
			end

		end
	end
end
