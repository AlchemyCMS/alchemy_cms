require 'alchemy/devise/ability'

Alchemy.register_ability(Alchemy::Devise::Ability)

Alchemy::Modules.register_module({
  name: 'users',
  engine_name: 'alchemy',
  position: 4.1,
  navigation: {
    name: 'modules.users',
    controller: 'alchemy/admin/users',
    action: 'index',
    icon: 'users',
    sub_navigation: [{
      name: 'modules.users',
      controller: 'alchemy/admin/users',
      action: 'index'
    }]
  }
})

Alchemy.user_class_name = 'Alchemy::User'
Alchemy.signup_path     = '/admin/signup'
Alchemy.login_path      = '/admin/login'
Alchemy.logout_path     = '/admin/logout'
