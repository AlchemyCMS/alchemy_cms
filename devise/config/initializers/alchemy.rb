# frozen_string_literal: true

Rails.application.config.to_prepare do
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

  Alchemy.config.signup_path = "/admin/signup"
  Alchemy.config.login_path = "/admin/login"
  Alchemy.config.logout_path = "/admin/logout"
  Alchemy.config.logout_method = Devise.sign_out_via.to_s
end
