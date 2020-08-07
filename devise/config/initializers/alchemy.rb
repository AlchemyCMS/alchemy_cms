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
    icon: "users",
  },
})

Alchemy.user_class_name = "Alchemy::User"
Alchemy.signup_path = "/admin/signup"
Alchemy.login_path = "/admin/login"
Alchemy.logout_path = "/admin/logout"

if Alchemy.respond_to?(:logout_method)
  Rails.application.config.after_initialize do
    Alchemy.logout_method = Devise.sign_out_via
  end
end
