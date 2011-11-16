module Alchemy
	class Notifications < ActionMailer::Base

		default :from => Alchemy::Config.get(:mailer)[:mail_from]

		def registered_user_created(user)
			@user = user
			@url = login_url
			mail(
				:to => user.email,
				:subject => I18n.t("alchemy.mailer.new_user_mail.subject")
			)
		end

		def admin_user_created(user)
			@user = user
			@url = admin_url
			mail(
				:to => user.email,
				:subject => _("Your Alchemy Login")
			)
		end

	end
end
