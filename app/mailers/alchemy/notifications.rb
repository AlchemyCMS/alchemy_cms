module Alchemy
  class Notifications < ActionMailer::Base

    default(from: Config.get(:mailer)['mail_from'])

    def registered_user_created(user)
      @user = user
      @url = login_url
      mail(
        to: user.email,
        subject: I18n.t("Your user credentials")
      )
    end

    def admin_user_created(user)
      @user = user
      @url = admin_url
      mail(
        to: user.email,
        subject: I18n.t("Your Alchemy Login")
      )
    end

    def reset_password_instructions(user, opts={})
      @user = user
      mail(
        to: user.email,
        subject: I18n.t("Reset password instructions")
      )
    end

  end
end
