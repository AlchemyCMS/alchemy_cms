# frozen_string_literal: true

Rails.application.config.to_prepare do
  Alchemy.register_ability Ability
  Alchemy.user_class_name = "DummyUser"
  Alchemy.signup_path = "/admin/pages" unless Rails.env.test?
  Alchemy::Modules.register_module(
    name: "events",
    navigation: {
      name: "Events",
      controller: "/admin/events",
      action: "index",
      icon: "calendar",
      sub_navigation: [{
        name: "Events",
        controller: "/admin/events",
        action: "index"
      }, {
        name: "Locations",
        controller: "/admin/locations",
        action: "index"
      }, {
        name: "Series",
        controller: "/admin/series",
        action: "index"
      }, {
        name: "Bookings",
        controller: "/admin/bookings",
        action: "index"
      }]
    }
  )
  Alchemy::Modules.register_module(
    name: "styleguide",
    engine_name: "alchemy",
    navigation: {
      name: "Styleguide",
      controller: "/alchemy/admin/styleguide",
      action: "index",
      icon: "palette"
    }
  )
end
