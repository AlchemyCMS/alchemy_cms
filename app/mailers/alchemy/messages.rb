module Alchemy
	class Messages < ActionMailer::Base

		default :from => Alchemy::Config.get(:mailer)[:mail_from]
  
		def contact_form_mail(message, mail_to, mail_from, subject)
			@message = message
			mail(
				:from => mail_from,
				:to => mail_to,
				:reply_to => message.email,
				:subject => subject
			)
		end

	end
end
