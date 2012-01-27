module Alchemy
	module Specs
		# Helpers for integration specs
		# This file is auto included in rspec integration/request tests.
		module Helpers

			# Capybara actions to login into Alchemy Backend
			# 
			# === IMPORTANT NOTE:
			# 
			# Because of a very strange bug in capybara, or rspec, or what ever, you **MUST** create the user inside a +before(:all)+ block inside your integrations specs.
			# 
			# === Example:
			# 
			#   before(:all) do
			#     Factory.build(:admin_user).save_without_session_maintenance
			#   end
			# 
			def login_into_alchemy
				visit '/alchemy/admin/login'
				fill_in('alchemy_user_session_login', :with => 'jdoe')
				fill_in('alchemy_user_session_password', :with => 's3cr3t')
				click_on('login')
			end

		end
	end
end

RSpec.configure do |c|
	c.include Alchemy::Specs::Helpers, :type => :request
end
