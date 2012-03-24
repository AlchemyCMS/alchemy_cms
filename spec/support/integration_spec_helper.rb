require 'declarative_authorization/maintenance'
include Authorization::TestHelper

# Trying to load additional authorization-rules in dummy-app.
# When accessing dummy-app in development-env it works without loading,
# in capybara-test this doesn't work. Unfortunately the method below doesn't work neither.
# I leave it here as a reminder
def load_authorization_rules
	Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
	Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../dummy' 'config/authorization_rules.rb'))
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


