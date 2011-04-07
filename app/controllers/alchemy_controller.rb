# This is the main Alchemy controller all other controllers inheret from.

class AlchemyController < ApplicationController

  include FastGettext::Translation
  include Alchemy
  include Userstamp

  protect_from_forgery
  filter_parameter_logging :login, :password, :password_confirmation

  before_filter :set_gettext_locale
  before_filter :set_translation
  before_filter :set_language

  helper_method :current_server, :configuration, :multi_language?, :current_user, :clipboard_empty?, :get_clipboard
  helper :errors, :layout

  def render_errors_or_redirect(object, redicrect_url, flash_notice)
    if object.errors.empty?
      flash[:notice] = _(flash_notice)
      render(:update) { |page| page.redirect_to(redicrect_url) }
    else
      render_remote_errors(object)
    end
  end
  
  def render_remote_errors(object)
    render :update do |page|
      page.replace_html 'errors', "<ul>" + object.errors.sum{|a, b| "<li>" + _(b) + "</li>"} + "</ul>"
      page.show "errors"
    end    
  end
  
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
    return Alchemy::Configuration.parameter(name)
  end
  
  def set_language_to(language_id)
    @language = Language.find(language_id)
    if @language
      session[:language_id] = @language.id
      session[:language_code] = @language.code
      Alchemy::Controller.current_language = @language
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
  
  def last_request_update_allowed?
    true #action_name =! "update_session_time_left"
  end
  
  # Handles exceptions
  def exception_handler(e)
    exception_logger(e)
    show_error_notice(e)
    # TODO: Exception Mailer!
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
    notice = "Error: #{e}"
    if request.xhr?
      render :update do |page|
        Alchemy::Notice.show(page, "Error: #{e}", :error)
      end
    else
      flash[:error] = notice
    end
  end
  
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
    end
    session[:language_id] = @language.id
    session[:language_code] = @language.code
    Alchemy::Controller.current_language = @language
    I18n.locale = @language.code
  end
  
  def store_location
    session[:redirect_url] = request.url
  end
  
  def set_stamper
    FastGettext.text_domain = 'alchemy'
    User.stamper = self.current_user
  end
  
  def reset_stamper
    User.reset_stamper
  end
  
protected
  
  def set_gettext_locale
    FastGettext.text_domain = 'alchemy'
    FastGettext.available_locales = configuration(:translations).collect { |l| l[:language_code] }
  end
  
  def set_translation
    if current_user.blank?
      FastGettext.locale = configuration(:default_translation)
    else
      FastGettext.locale = current_user.language
    end
  end
  
  def set_language
    if session[:language_id].blank?
      set_language_to_default
    end
  rescue
    log_error($!)
    flash[:error] = _('no_default_language_found')
  end
  
  def permission_denied
    if current_user
      flash[:error] = _('You are not authorized')
      if current_user.role == 'registered'
        redirect_to root_path
      else
        if request.referer == login_url
          render :text => 'Not allowed'
        else
          redirect_to admin_path
        end
      end
    else
      flash[:info] = _('Please log in')
      if request.xhr?
        render :update do |page|
          page.redirect_to login_path
        end
      else
        store_location
        redirect_to login_path
      end
    end
  end
  
  def redirect_back_or_to_default(default_path = admin_path)
    if request.env["HTTP_REFERER"].blank?
      redirect_to default_path
    else
      redirect_to :back
    end
  end
  
  def set_language_to_default
    @language = Language.get_default
    session[:language_id] = @language.id
    session[:language_code] = @language.code
    Alchemy::Controller.current_language = @language
    I18n.locale = @language.code
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
  
end
