module Alchemy
  module Locale
    extend ActiveSupport::Concern

    included do
      before_action :set_translation
    end

    private

    # Sets Alchemy's GUI translation.
    #
    #   * If one passed a locale via +params[:locale]+ it uses this.
    #   * Or it tries to get users preffered language.
    #   * If not found it guesses the language from the browser locale.
    #   * If that also fails it takes the default.
    #
    # It respects the default translation from your +config/application.rb+ +default_locale+ config option.
    #
    def set_translation
      if locale_change_needed?
        ::I18n.locale = session[:alchemy_locale] = locale_from_params ||
          locale_from_user || locale_from_browser || ::I18n.default_locale
      else
        ::I18n.locale = session[:alchemy_locale]
      end
    end

    # Checks if we need to change to locale or not.
    def locale_change_needed?
      params[:locale].present? || session[:alchemy_locale].blank?
    end

    # Try to get the locale from +params[:locale]+.
    def locale_from_params
      return if params[:locale].blank?
      if ::I18n.available_locales.include?(params[:locale].to_sym)
        params[:locale]
      end
    end

    # Try to get the locale from user settings.
    def locale_from_user
      return if !current_alchemy_user
      if user_has_preferred_language?
        current_alchemy_user.language
      end
    end

    # Checks if the +current_alchemy_user+ has a preferred language set or not.
    def user_has_preferred_language?
      return if !current_alchemy_user
      current_alchemy_user.respond_to?(:language) &&
        current_alchemy_user.language.present?
    end

    # Try to get the locale from browser headers.
    def locale_from_browser
      request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /\A[a-z]{2}/).try(:first)
    end

  end
end
