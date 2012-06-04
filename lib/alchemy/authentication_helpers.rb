module Alchemy
  module AuthenticationHelpers

    def self.included(base)
      base.send :alias_method, :current_alchemy_user, :current_user
      base.send :helper_method, :current_user
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

  end
end

ApplicationController.send :include, Alchemy::AuthenticationHelpers
