module Alchemy
	class UserSession < Authlogic::Session::Base
		logout_on_timeout(::Rails.env != 'development')

		generalize_credentials_error_messages true

		before_destroy :unlock_pages

		def unlock_pages
			self.user.unlock_pages if self.user
		end

	end
end
