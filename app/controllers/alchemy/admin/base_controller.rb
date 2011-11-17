module Alchemy
	module Admin
		class BaseController < Alchemy::BaseController
			include Userstamp

			helper_method :clipboard_empty?, :trash_empty?, :get_clipboard, :is_admin?

			filter_access_to :all

			rescue_from Exception, :with => :exception_handler

			layout 'alchemy/admin'

		private

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
				if request.xhr?
					render :action => "error_notice"
				else
					flash[:error] = @notice
					redirect_back_or_to_default
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
				clipboard[category.to_sym] ||= [] if category
			end

			def clipboard_empty?(category = nil)
				return true if session[:clipboard].blank?
				if category
					session[:clipboard][category.to_sym].blank?
				else
					false
				end
			end
  
			def trash_empty?(category)
				category.singularize.classify.constantize.trashed.blank?
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
					flash[:notice] = _(flash_notice)
					render :action => :redirect
				else
					render_remote_errors(object, button)
				end
			end

			def render_remote_errors(object, button = nil)
				@button = button
				@errors = ("<ul>" + object.errors.sum { |a, b| "<li>" + _(b) + "</li>" } + "</ul>").html_safe
				render :action => :remote_errors
			end

		end
	end
end
