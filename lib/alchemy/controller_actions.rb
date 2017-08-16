# frozen_string_literal: true

module Alchemy
  module ControllerActions
    extend ActiveSupport::Concern

    included do
      before_action :set_current_alchemy_site
      before_action :set_alchemy_language

      helper 'alchemy/pages'

      helper_method :current_alchemy_user,
        :alchemy_user_signed_in?,
        :current_alchemy_site,
        :current_server
    end

    private

    # Returns a host string with the domain the app is running on.
    def current_server
     "#{request.protocol}#{request.host_with_port}"
    end

    # The current authorized user.
    #
    # In order to have Alchemy's authorization work, you have to
    # provide a +current_user+ method in your app's ApplicationController,
    # that returns the current user. To change the method +current_alchemy_user+
    # will call, set +Alchemy.current_user_method+ to a different method name.
    #
    # If you don't have an App that can provide a +current_user+ object,
    # you can install the `alchemy-devise` gem that provides everything you need.
    #
    def current_alchemy_user
      current_user_method = Alchemy.current_user_method
      raise NoCurrentUserFoundError if !respond_to?(current_user_method, true)
      send current_user_method
    end

    # Returns true if a +current_alchemy_user+ is present
    #
    def alchemy_user_signed_in?
      current_alchemy_user.present?
    end

    # Returns the current site.
    #
    def current_alchemy_site
      @current_alchemy_site ||= Site.find_for_host(request.host)
    end

    # Sets the current site in a cvar so the Language model
    # can be scoped against it.
    #
    def set_current_alchemy_site
      Site.current = current_alchemy_site
    end

    # Try to find and stores current language for Alchemy.
    #
    def set_alchemy_language(lang = nil)
      if lang
        @language = lang.is_a?(Language) ? lang : load_alchemy_language_from_id_or_code(lang)
      else
        # find the best language and remember it for later
        @language = load_alchemy_language_from_params ||
                    load_alchemy_language_from_session ||
                    Language.default
      end
      store_current_alchemy_language(@language)
    end

    def load_alchemy_language_from_params
      if params[:locale].present?
        Language.find_by_code(params[:locale])
      end
    end

    # Load language from session if it's present on current site.
    # Otherwise return nil so we can load the default language from current site.
    def load_alchemy_language_from_session
      if session[:alchemy_language_id].present?
        Site.current.languages.find_by(id: session[:alchemy_language_id])
      end
    end

    def load_alchemy_language_from_id_or_code(id_or_code)
      Language.find_by(id: id_or_code) ||
        Language.find_by_code(id_or_code)
    end

    # Stores language's id in the session.
    #
    # Also stores language in +Language.current+
    #
    def store_current_alchemy_language(language)
      if language && language.id
        session[:alchemy_language_id] = language.id
        Language.current = language
      end
    end
  end
end
