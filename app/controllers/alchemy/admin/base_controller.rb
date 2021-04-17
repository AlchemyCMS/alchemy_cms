# frozen_string_literal: true

module Alchemy
  module Admin
    class BaseController < Alchemy::BaseController
      include Userstamp
      include Locale

      before_action :load_locked_pages

      helper_method :clipboard_empty?, :get_clipboard, :is_admin?

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

      def leave
        authorize! :leave, :alchemy_admin
        render template: "/alchemy/admin/leave", layout: !request.xhr?
      end

      private

      # Disable layout rendering for xhr requests.
      def set_layout
        request.xhr? ? false : "alchemy/admin"
      end

      # Handles exceptions
      def exception_handler(error)
        exception_logger(error)
        show_error_notice(error)
        if defined?(Airbrake)
          notify_airbrake(error) unless Rails.env.development? || Rails.env.test?
        end
      end

      # Displays an error notice in the Alchemy backend.
      def show_error_notice(error)
        @error = error
        # truncate the message, because very long error messages (i.e from mysql2) causes cookie overflow errors
        @notice = error.message[0..255]
        @trace = error.backtrace[0..50]
        if request.xhr?
          render action: "error_notice"
        else
          respond_to do |format|
            format.html { render "500", status: 500 }
            format.json { render json: { message: @notice }, status: 500 }
          end
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
          flash[:notice] = Alchemy.t(flash_notice)
          do_redirect_to redirect_url
        else
          render action: (params[:action] == "update" ? "edit" : "new")
        end
      end

      # Does redirects for html and js requests
      #
      def do_redirect_to(url_or_path)
        respond_to do |format|
          format.js {
            @redirect_url = url_or_path
            render :redirect
          }
          format.html { redirect_to url_or_path }
        end
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
        controller_path == "alchemy/admin/pages" && action_name == "show"
      end

      def load_locked_pages
        @locked_pages = Page.locked_by(current_alchemy_user).order(:locked_at)
      end

      # Returns the current site for admin controllers.
      #
      def current_alchemy_site
        @current_alchemy_site ||= begin
            site_id = params[:site_id] || session[:alchemy_site_id]
            site = Site.find_by(id: site_id) || super
            session[:alchemy_site_id] = site&.id
            site
          end
      end
    end
  end
end
