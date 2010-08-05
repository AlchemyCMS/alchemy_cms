class ActionController::Base
  def set_gettext_locale
    requested_locale = params[:locale] || session[:locale] || cookies[:locale] ||  request.env['HTTP_ACCEPT_LANGUAGE']
    session[:locale] = FastGettext.set_locale(requested_locale)
  end
end