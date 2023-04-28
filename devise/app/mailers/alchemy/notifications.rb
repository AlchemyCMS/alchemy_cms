module Alchemy
  class Notifications < ActionMailer::Base
    default(from: Config.get(:mailer)["mail_from"])

    def member_created(user)
      @user = user

      mail(
        to: user.email,
        subject: Alchemy.t("Your user credentials")
      )
    end

    def alchemy_user_created(user)
      @user = user
      @url = admin_url
      mail(
        to: user.email,
        subject: Alchemy.t("Your Alchemy Login")
      )
    end

    def reset_password_instructions(user, token, opts = {})
      @user = user
      @token = token
      mail(
        to: user.email,
        subject: Alchemy.t("Reset password instructions")
      )
    end
  end
end
