class UserSession < Authlogic::Session::Base
  logout_on_timeout(Rails.env != 'development')
  
  before_destroy :unlock_pages
  
  def unlock_pages
    self.user.unlock_pages if self.user
  end
  
end
