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
          render :action => "error_notice", :layout => false
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

      def get_clipboard
        session[:clipboard] ||= Clipboard.new
      rescue NoMethodError => e
        exception_logger(e)
        @notice = "You have an old style clipboard in your session. Please remove your cookies and try again."
        render :action => "error_notice", :layout => false
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
        User.stamper = current_user
      end

      def reset_stamper
        User.reset_stamper
      end

      # Returns true if the current_user (The logged-in Alchemy User) has the admin role.
      def is_admin?
        return false if !current_user
        current_user.admin?
      end

      # Displays errors in a #errors div if any errors are present on the object.
      # Or redirects to the given redirect url.
      def render_errors_or_redirect(object, redirect_url, flash_notice)
        if object.errors.empty?
          @redirect_url = redirect_url
          flash[:notice] = t(flash_notice)
          render :action => :redirect
        else
          render_remote_errors(object)
        end
      end

      # Displays an unordered list of objects errors in an errors div.
      # You have to add a hidden div with the id '#errors' to make this work.
      # You can pass a div id as second argument to display the errors in alternative div.
      def render_remote_errors(object, error_div_id = '#errors')
        @error_div_id = error_div_id
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
