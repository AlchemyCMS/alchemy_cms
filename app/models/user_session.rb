class UserSession < Authlogic::Session::Base
  logout_on_timeout(Rails.env != 'development')
  
  before_destroy :unlock_pages
  
  def unlock_pages
    self.record.unlock_pages
  end
  
end
