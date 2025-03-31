# frozen_string_literal: true

Rails.application.config.to_prepare do
  require "alchemy/devise/ability"

  Alchemy.register_ability(Alchemy::Devise::Ability)

  Alchemy::Modules.register_module({
    name: "users",
    engine_name: "alchemy",
    position: 4.1,
    navigation: {
      name: "modules.users",
      controller: "/alchemy/admin/users",
      action: "index",
      icon: "group"
    }
  })

  Alchemy.signup_path = "/admin/signup"
  Alchemy.login_path = "/admin/login"
  Alchemy.logout_path = "/admin/logout"
  Alchemy.logout_method = Devise.sign_out_via
end
