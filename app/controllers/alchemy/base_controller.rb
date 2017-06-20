# This is the main Alchemy controller all other controllers inherit from.
#
module Alchemy
  class BaseController < ApplicationController
    include Alchemy::ConfigurationMethods
    include Alchemy::AbilityHelper
    include Alchemy::ControllerActions
    include Alchemy::Modules
    include Alchemy::SSLProtection

    protect_from_forgery

    before_action :mailer_set_url_options
    before_action :set_locale

    helper 'alchemy/admin/form'

    rescue_from CanCan::AccessDenied do |exception|
      permission_denied(exception)
    end

    private

    # Sets +I18n.locale+ to current Alchemy language.
    #
    def set_locale
      ::I18n.locale = Language.current.locale
    end

    def not_found_error!(msg = "Not found \"#{request.fullpath}\"")
      raise ActionController::RoutingError, msg
    end

    # Shortcut for Alchemy::I18n.translate method
    def _t(key, *args)
      ActiveSupport::Deprecation.warn("Alchemys `_t` method is deprecated! Use `Alchemy.t` instead.", caller.unshift)
      Alchemy.t(key, *args)
    end

    # Store current request path into session,
    # so we can later redirect to it.
    def store_location
      session[:redirect_path] = request.path
    end

    def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end

    protected

    def permission_denied(exception = nil)
      if exception
        Rails.logger.debug <<-WARN.strip_heredoc
          /!\\ Failed to permit #{exception.action} on #{exception.subject.inspect} for:
          #{current_alchemy_user.inspect}
        WARN
      end
      if current_alchemy_user
        handle_redirect_for_user
      else
        handle_redirect_for_guest
      end
    end

    def handle_redirect_for_user
      flash[:warning] = Alchemy.t('You are not authorized')
      if can?(:index, :alchemy_admin_dashboard)
        redirect_or_render_notice
      else
        redirect_to('/')
      end
    end

    def redirect_or_render_notice
      if request.xhr?
        respond_to do |format|
          format.js do
            render text: flash.discard(:warning), status: 403
          end
          format.html do
            render partial: 'alchemy/admin/partials/flash',
              locals: {message: flash[:warning], flash_type: 'warning'}
          end
        end
      else
        redirect_to(alchemy.admin_dashboard_path)
      end
    end

    def handle_redirect_for_guest
      flash[:info] = Alchemy.t('Please log in')
      if request.xhr?
        render :permission_denied
      else
        store_location
        redirect_to Alchemy.login_path
      end
    end

    # Logs the current exception to the error log.
    def exception_logger(e)
      Rails.logger.error("\n#{e.class} #{e.message} in #{e.backtrace.first}")
      Rails.logger.error(e.backtrace[1..50].each { |l| l.gsub(/#{Rails.root.to_s}/, '') }.join("\n"))
    end
  end
end
