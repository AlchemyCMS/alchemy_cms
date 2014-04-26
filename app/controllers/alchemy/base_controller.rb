# This is the main Alchemy controller all other controllers inherit from.
#
module Alchemy
  class BaseController < ApplicationController
    include Alchemy::Modules

    protect_from_forgery

    before_action :mailer_set_url_options
    before_action :set_locale

    helper_method :multi_site?

    helper 'alchemy/admin/form'

    rescue_from CanCan::AccessDenied do |exception|
      permission_denied(exception)
    end

    def leave
      render layout: !request.xhr?
    end

    private

    # Sets +I18n.locale+ to current Alchemy language.
    #
    def set_locale
      ::I18n.locale = Language.current.code
    end

    # Returns the configuration value of given key.
    #
    # Config file is in +config/alchemy/config.yml+
    #
    def configuration(name)
      Alchemy::Config.get(name)
    end

    def multi_language?
      Language.published.count > 1
    end

    def multi_site?
      Site.count > 1
    end

    def raise_not_found_error
      raise ActionController::RoutingError.new('Not Found')
    end

    # Shortcut for Alchemy::I18n.translate method
    def _t(key, *args)
      I18n.t(key, *args)
    end

    # Store current request path into session,
    # so we can later redirect to it.
    def store_location
      session[:redirect_path] = request.path
    end

    def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end

    def render_404(exception = nil)
      if exception
        logger.info "Rendering 404: #{exception.message}"
      end
      render :file => Rails.root.join("public/404.html"), :status => 404, :layout => false
    end

    # Enforce ssl for login and all admin modules.
    #
    # Default is +false+
    #
    # === Usage
    #
    #   #config.yml
    #   require_ssl: true
    #
    # === Note
    #
    # You have to create a ssl certificate if you want to use the ssl protection
    #
    def ssl_required?
      (Rails.env == 'production' || Rails.env == 'staging') && configuration(:require_ssl)
    end

    # Redirects request to ssl.
    def enforce_ssl
      redirect_to url_for(protocol: 'https')
    end

    protected

    def permission_denied(exception = nil)
      Rails.logger.debug <<-WARN

/!\\ Failed to permit #{exception.action} on #{exception.subject.inspect} for:
#{current_alchemy_user.inspect}
WARN
      if current_alchemy_user
        handle_redirect_for_user
      else
        handle_redirect_for_guest
      end
    end

    def handle_redirect_for_user
      flash[:warning] = _t('You are not authorized')
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
      flash[:info] = _t('Please log in')
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

    def raise_authorization_exception(exception)
      raise("Not permitted to #{exception.action} #{exception.subject}")
    end

  end
end
