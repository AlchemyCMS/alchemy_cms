class Mailer < ActionMailer::Base
  
  def mail(mail_data, mail_to, mail_from, subject)
    recipients(mail_to)
    subject(subject)
    reply_to(mail_data[:email])
    from(mail_from || Alchemy::Configuration.parameter(:mailer)[:mail_from])
    body({:mail_data => mail_data})
  end
  
  def new_user_mail(user, request, mail_from = Alchemy::Configuration.parameter(:mailer)[:mail_from])
    recipients(user.email)
    from(mail_from)
    subject(I18n.t("alchemy.mailer.new_user_mail.subject"))
    sent_on(Time.now)
    body({:user => user, :url => "#{request.protocol}#{request.host}/admin/login"})
  end
  
  def new_alchemy_user_mail(user, request, mail_from = Alchemy::Configuration.parameter(:mailer)[:mail_from])
    recipients(user.email)
    from(mail_from)
    subject( _("Your Alchemy Login") )
    sent_on(Time.now)
    body({:user => user, :url => "#{request.protocol}#{request.host}/admin"})
  end
  
end
