require 'declarative_authorization/maintenance'

include Authorization::TestHelper

def admin_user
	return @admin_user unless @admin_user.nil?
	@admin_user = Factory.create(:admin_user)
	#@admin_user.save_without_session_maintenance
	#@admin_user
end


