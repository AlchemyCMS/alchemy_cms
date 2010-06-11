class Mailer < ActionMailer::Base
  
  def mail(mail_data, mail_to, mail_from, subject)
    # Email header info MUST be added here
    recipients mail_to
    from mail_from
    subject subject
    # Email body substitutions go here
    body :mail_data => mail_data
  end
  
  def new_user_mail(user, request)
    recipients(user.email)
    from(Alchemy::Configuration.parameter(:mailer)[:mail_from])
    subject( I18n.t("mailer.new_user_mail.subject") )
    sent_on(Time.now)
    body({:user => user, :url => "#{request.protocol}#{request.host}/admin/login"})
  end
  
  def new_alchemy_user_mail(user, request)
    recipients(user.email)
    from(Alchemy::Configuration.parameter(:mailer)[:mail_from])
    subject( _("Your Alchemy Login") )
    sent_on(Time.now)
    body({:user => user, :url => "#{request.protocol}#{request.host}/admin"})
  end
  
end
