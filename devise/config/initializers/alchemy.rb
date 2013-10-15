Alchemy::Modules.register_module({
  name: 'users',
  engine_name: 'alchemy',
  navigation: {
    name: 'modules.users',
    controller: 'alchemy/admin/users',
    action: 'index',
    icon: 'users',
    sub_navigation: {
      name: 'modules.users',
      controller: 'alchemy/admin/users',
      action: 'index'
    }
  }
})
