class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def current_user
    if Rails.env.test?
      nil
    else
      DummyUser.new(email: "dummy@alchemy.com")
    end
  end
end
