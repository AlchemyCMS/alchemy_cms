require 'declarative_authorization/maintenance'
include Authorization::TestHelper

# Load additional authorization_rules for specs.
# For some strange reason, this isn't done automatically while running the specs
def load_authorization_rules
  instance = Alchemy::AuthEngine.get_instance
  instance.load(File.join(File.dirname(__FILE__), '../dummy', 'config/authorization_rules.rb'))
  instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
end

def create_admin_user
  @user = Alchemy::User.create!(:login => 'admin_user', :password => 's3cr3t', :password_confirmation => 's3cr3t', :email => 'jdoe2@example.com', :role => :admin)
end

def login_with_admin_user
  visit '/alchemy/admin/login'
  fill_in('alchemy_user_session_login', :with => 'admin_user')
  fill_in('alchemy_user_session_password', :with => 's3cr3t')
  click_on('Login')
end
