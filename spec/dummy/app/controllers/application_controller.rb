# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  # In development authentication is handled by the alchemy-devise engine,
  # which provides its own +current_user+ helper, so we must not shadow it.
  unless Rails.env.development?
    def current_user
      return if Rails.env.test?

      @_dummy_user ||= DummyUser.find_or_create_by(email: "dummy@alchemy.com")
    end
  end
end
