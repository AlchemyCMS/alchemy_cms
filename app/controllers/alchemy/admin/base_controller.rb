module Alchemy
  module Admin
    class BaseController < Alchemy::BaseController
      include Userstamp
      include Alchemy::Locale

      before_filter { enforce_ssl if ssl_required? && !request.ssl? }

      helper_method :clipboard_empty?, :trash_empty?, :get_clipboard, :is_admin?

      check_authorization

      rescue_from Exception do |exception|
        if exception.is_a? CanCan::AccessDenied
          permission_denied(exception)
        elsif raise_exception?
          raise
        else
          exception_handler(exception)
        end
      end

      layout :set_layout

      private

      # Disable layout rendering for xhr requests.
      def set_layout
        request.xhr? ? false : 'alchemy/admin'
      end

      # Handles exceptions
      def exception_handler(e)
        exception_logger(e)
        show_error_notice(e)
        if defined?(Airbrake)
          notify_airbrake(e) unless Rails.env.development? || Rails.env.test?
        end
      end

      # Displays an error notice in the Alchemy backend.
      def show_error_notice(e)
        @error = e
        # truncate the message, because very long error messages (i.e from mysql2) causes cookie overflow errors
        @notice = e.message[0..255]
        @trace = e.backtrace[0..50]
        if request.xhr?
          render :action => "error_notice"
        else
          render '500', :status => 500
        end
      end

      def redirect_back_or_to_default(default_path = admin_dashboard_path)
        if request.referer.present?
          redirect_to :back
        else
          redirect_to default_path
        end
      end

      # Returns clipboard items for given category
      def get_clipboard(category)
        session[:alchemy_clipboard] ||= {}
        session[:alchemy_clipboard][category.to_s] ||= []
      end

      # Checks if clipboard for given category is blank
      def clipboard_empty?(category)
        get_clipboard(category).blank?
      end

      def trash_empty?(category)
        "alchemy/#{category.singularize}".classify.constantize.trashed.blank?
      end

      def set_stamper
        if Alchemy.user_class < ActiveRecord::Base
          Alchemy.user_class.stamper = current_alchemy_user
        end
      end

      def reset_stamper
        if Alchemy.user_class < ActiveRecord::Base
          Alchemy.user_class.reset_stamper
        end
      end

      # Returns true if the current_alchemy_user (The logged-in Alchemy User) has the admin role.
      def is_admin?
        return false if !current_alchemy_user
        current_alchemy_user.admin?
      end

      # Displays errors in a #errors div if any errors are present on the object.
      # Or redirects to the given redirect url.
      #
      # @param object [ActiveRecord::Base]
      # @param redirect_url [String]
      # @param flash_notice [String]
      #
      def render_errors_or_redirect(object, redirect_url, flash_notice)
        if object.errors.empty?
          flash[:notice] = _t(flash_notice)
          do_redirect_to redirect_url
        else
          render action: (params[:action] == 'update' ? 'edit' : 'new')
        end
      end

      def per_page_value_for_screen_size
        return 25 if session[:screen_size].blank?
        screen_height = session[:screen_size].split('x').last.to_i
        (screen_height / 30) - 10
      end

      # Does redirects for html and js requests
      #
      def do_redirect_to(url_or_path)
        respond_to do |format|
          format.js   {
            @redirect_url = url_or_path
            render :redirect
          }
          format.html { redirect_to url_or_path }
        end
      end

      # Extracts options from params.
      #
      # Helps to parse JSONified options into Hash or Array
      #
      def options_from_params
        case params[:options]
        when ''
          {}
        when String
          JSON.parse(params[:options])
        when Hash
          params[:options]
        when Array
          params[:options]
        else
          {}
        end.symbolize_keys
      end

      # This method decides if we want to raise an exception or not.
      #
      # I.e. in test environment.
      #
      def raise_exception?
        Rails.env.test? || is_page_preview?
      end

      # Are we currently in the page edit mode page preview.
      def is_page_preview?
        controller_path == 'alchemy/admin/pages' && action_name == 'show'
      end

    end
  end
end
