# frozen_string_literal: true

Rails.application.config.to_prepare do
  Alchemy.config.abilities.add("Alchemy::Devise::Ability")

  # to_prepare runs again on every code reload
  unless Alchemy.config.menu.any? { |item| item.name == "users" }
    Alchemy.config.menu.add(
      name: "users",
      title: "modules.users",
      position: 4.1,
      icon: "group",
      url: -> { alchemy.admin_users_path },
      condition: -> { can?(:index, :alchemy_admin_users) }
    )
  end

  Alchemy.config.signup_path = "/admin/signup"
  Alchemy.config.login_path = "/admin/login"
  Alchemy.config.logout_path = "/admin/logout"
  Alchemy.config.logout_method = Devise.sign_out_via.to_s
  Alchemy.config.edit_user_path = "/admin/users/:id/edit"
  Alchemy.config.admin_users_path = "/admin/users"
end
