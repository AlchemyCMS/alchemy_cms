class Messages < ActionMailer::Base
  
  default :from => Alchemy::Config.get(:mailer)[:mail_from]
  
  def mail(mail_data, mail_to, mail_from, subject)
    @mail_data = mail_data
    mail(
      :from => mail_from,
      :to => mail_to,
      :reply_to => mail_data[:email],
      :subject => subject
    )
  end
  
end
