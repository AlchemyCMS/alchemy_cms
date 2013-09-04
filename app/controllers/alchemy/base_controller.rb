require 'alchemy/modules'

# This is the main Alchemy controller all other controllers inheret from.
module Alchemy
  class BaseController < ApplicationController
    include Alchemy::Modules

    protect_from_forgery

    before_filter :set_current_site
    before_filter :set_language
    before_filter :mailer_set_url_options
    before_filter :store_user_request_time

    helper_method :current_server, :current_site, :multi_site?

    rescue_from CanCan::AccessDenied do |exception|
      permission_denied(exception)
    end

    # Returns a host string with the domain the app is running on.
    def current_server
     "#{request.protocol}#{request.host_with_port}"
    end

    # Returns the configuratin value of given key.
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

  private

    # Ensures usage of Alchemy's permissions class.
    #
    # Also merges existing abilities.
    #
    def current_ability
      @current_ability ||= begin
        alchemy_permissions = ::Alchemy::Permissions.new(current_user)
        # Ruby, ruby, ruby...... o.O
        if (Object.const_get('Ability') rescue false)
          alchemy_permissions.merge(Ability.new(current_user))
        else
          alchemy_permissions
        end
      end
    end

    # Returns the current site.
    #
    def current_site
      @current_site ||= Site.find_for_host(request.host)
    end

    # Sets the current site in a cvar so the Language model
    # can be scoped against it.
    #
    def set_current_site
      Site.current = current_site
    end

    # Sets Alchemy's GUI translation to users preffered language and stores it in the session.
    #
    # Guesses the language from browser locale. If not successful it takes the default.
    #
    # You can set the default translation in your +config/application.rb+ file, via Rails +default_locale+ config option.
    #
    # If one passes a locale parameter the locale is set to its value
    #
    def set_translation
      if params[:locale].blank? && session[:current_locale].present?
        ::I18n.locale = session[:current_locale]
      elsif params[:locale].present? && ::I18n.available_locales.include?(params[:locale].to_sym)
        session[:current_locale] = ::I18n.locale = params[:locale]
      elsif current_user && current_user.language.present?
        ::I18n.locale = current_user.language
      else
        ::I18n.locale = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /\A[a-z]{2}/).try(:first) || ::I18n.default_locale
      end
    end

    # Sets the language for rendering pages in pages controller.
    #
    def set_language(lang = nil)
      if lang
        @language = lang.is_a?(Language) ? lang : load_language_from(lang)
      else
        # find the best language and remember it for later
        @language = load_language_from_params ||
                    load_language_from_session ||
                    load_language_default
      end

      # store language in session
      store_language_in_session(@language)

      # switch locale to selected language
      ::I18n.locale = @language.code
    end

    def load_language_from_params
      if params[:lang].present?
        Language.find_by_code(params[:lang])
      end
    end

    def load_language_from_session
      if session[:language_id].present?
        Language.find_by_id(session[:language_id])
      end
    end

    def load_language_from(language_code_or_id)
      Language.find_by_id(language_code_or_id) || Language.find_by_code(language_code_or_id)
    end

    def load_language_default
      Language.get_default || raise(DefaultLanguageNotFoundError)
    end

    def store_language_in_session(language)
      if language && language.id
        session[:language_id]   = language.id
        session[:language_code] = language.code
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

    # Returns the layout to be used by the current page. This method is being
    # used in PageController#show's invocation of #render.
    #
    # It allows you to request a specific page layout by passing a 'layout' parameter
    # in a request. If this parameter is set to 'none' or 'false', no layout whatsoever
    # will be used to render the page; otherwise, a layout by the given name
    # will be applied.
    #
    def layout_for_page
      if params[:layout] == 'none' || params[:layout] == 'false'
        false
      else
        params[:layout] || 'application'
      end
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

    # Stores the users request time.
    def store_user_request_time
      if user_signed_in?
        current_user.store_request_time!
      end
    end

  protected

    def permission_denied(exception = nil)
      Rails.logger.warn <<-WARN

/!\\ Failed to permit #{exception.action} on #{exception.subject.inspect} for:
#{current_user.inspect}
WARN
      if current_user
        handle_redirect_for_user
      else
        handle_redirect_for_guest
      end
    end

    def handle_redirect_for_user
      if can?(:index, :alchemy_admin_dashboard)
        redirect_or_render_notice
      else
        redirect_to('/')
      end
    end

    def redirect_or_render_notice
      if request.xhr?
        respond_to do |format|
          format.js { render status: 403 }
          format.html {
            render(partial: 'alchemy/admin/partials/flash', locals: {message: _t('You are not authorized'), flash_type: 'warning'})
          }
        end
      else
        flash[:warning] = _t('You are not authorized')
        redirect_to(alchemy.admin_dashboard_path)
      end
    end

    def handle_redirect_for_guest
      flash[:info] = _t('Please log in')
      if request.xhr?
        render(:action => :permission_denied)
      else
        store_location
        redirect_to(alchemy.login_path)
      end
    end

    # Logs the current exception to the error log.
    def exception_logger(e)
      Rails.logger.error("\n#{e.class} #{e.message} in #{e.backtrace.first}")
      Rails.logger.error(e.backtrace[1..50].each { |l| l.gsub(/#{Rails.root.to_s}/, '') }.join("\n"))
    end

  end
end
