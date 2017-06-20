class LoginController < ApplicationController
  def new
    render plain: 'Please login'
  end
end
