# frozen_string_literal: true

Rails.application.config.to_prepare do
  require "alchemy/devise/ability"

  alchemy_7_4 = Gem::Version.new("7.4.0.a")

  icon = if Alchemy.gem_version.between? Gem::Version.new("7.1.0-b1"), alchemy_7_4
    "group-line"
  elsif Alchemy.gem_version > alchemy_7_4
    "group"
  else
    "users"
  end

  Alchemy.register_ability(Alchemy::Devise::Ability)

  Alchemy::Modules.register_module({
    name: "users",
    engine_name: "alchemy",
    position: 4.1,
    navigation: {
      name: "modules.users",
      controller: "/alchemy/admin/users",
      action: "index",
      icon: icon
    }
  })

  Alchemy.signup_path = "/admin/signup"
  Alchemy.login_path = "/admin/login"
  Alchemy.logout_path = "/admin/logout"
  Alchemy.logout_method = Devise.sign_out_via
end
