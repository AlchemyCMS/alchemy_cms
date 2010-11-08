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

  helper_method :current_server, :configuration, :multi_language?, :current_user
  helper :errors, :layout

  def render_errors_or_redirect object, redicrect_url, flash_notice
    if object.errors.empty?
      flash[:notice] = _(flash_notice)
      render :update do |page| page.redirect_to redicrect_url end
    else
      render :update do |page|
        page.replace_html 'errors', "<ul>" + object.errors.sum{|a, b| "<li>" + _(b) + "</li>"} + "</ul>"
        page.show "errors"
        page << "alchemy_window.updateHeight()"
      end
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
  
  def set_language_to(lang = nil)
    language_code = Language.find_code_for(params[:lang] || lang)
    if language_code
      session[:language] = language_code
      Alchemy::Controller.current_language = session[:language]
    else
      logger.error "+++++++ Language not found for code: #{language_code}"
    end
  end
  
  def multi_language?
    Language.count > 1
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
  
  def exception_handler(e)
    logger.error %(
      +++++++++ #{e} +++++++++++++
      object: #{e.record.class}, id: #{e.record.id}, name: #{e.record.name}
      #{e.record.errors.full_messages}
    )
  end
  
  def set_language_from_client
    if params[:lang].blank?
      lang = request.env['HTTP_ACCEPT_LANGUAGE'][0..1] unless request.env['HTTP_ACCEPT_LANGUAGE'].blank?
      language_code = lang
    else
      language_code = params[:lang]
    end
    language = Language.find_code_for(language_code)
    if language.blank?
      logger.warn "+++++++ Language not found for code: #{language_code}"
      render :file => Rails.root + 'public/404.html', :code => 404
    else
      session[:language] = language
      Alchemy::Controller.current_language = session[:language]
      I18n.locale = session[:language]
    end
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
    FastGettext.locale = current_user.language unless current_user == :false || current_user.blank?
  end
  
  def set_language
    session[:language] ||= configuration(:default_language).blank? ? 'de' : configuration(:default_language)
    Alchemy::Controller.current_language = session[:language]
    I18n.locale = session[:language]
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
  
end
