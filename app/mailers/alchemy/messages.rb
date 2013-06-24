module Alchemy
  class Messages < ActionMailer::Base

    def contact_form_mail(message, mail_to, mail_from, subject)
      @message = message
      mail(
        from: mail_from,
        to: mail_to,
        reply_to: message.try(:email),
        subject: subject
      )
    end

  end
end
