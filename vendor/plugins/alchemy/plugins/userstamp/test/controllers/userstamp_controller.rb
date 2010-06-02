class UserstampController < ActionController::Base
  include Ddb::Controller::Userstamp

  protected
    def current_user
      User.find(session[:user_id])
    end
  #end
end