class Mailer < ActionMailer::Base

  def mail(mail_data, mail_to, mail_from, subject)
    recipients(mail_to)
    subject(subject)
    reply_to(mail_data[:email])
    from(mail_from || Alchemy::Config.parameter(:mailer)[:mail_from])
    body({:mail_data => mail_data})
  end

end
