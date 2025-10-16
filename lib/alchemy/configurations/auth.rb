# frozen_string_literal: true

module Alchemy
  module Configurations
    class Auth < Alchemy::Configuration
      # Provides authentication configuration.
      #
      # Alchemy has some defaults for user model name and login logout path names:
      #
      # +Alchemy.config.auth.user_class+ has no default.
      # +Alchemy.config.auth.user_class_primary_key+ defaults to +:id+
      # +Alchemy.config.auth.current_user_method defaults to +'current_user'+
      # +Alchemy.config.auth.signup_path defaults to +'/signup'+
      # +Alchemy.config.auth.login_path defaults to +'/login'+
      # +Alchemy.config.auth.logout_path defaults to +'/logout'+
      # +Alchemy.config.auth.logout_method defaults to +'delete'+
      # +Alchemy.config.auth.unauthorized_path defaults to +'/'+
      #
      # Anyway, you can tell Alchemy about your authentication model configuration:
      #
      #   1. Your user class name - @see: #auth.user_class
      #   2. Your users table primary key - @see: #user_class_primary_key
      #   3. A method on your ApplicationController to get current user -
      #      @see: #current_user_method
      #   4. The path to the signup form - @see: #signup_path
      #   5. The path to the login form - @see: #login_path
      #   6. The path to the logout method - @see: #logout_path
      #   7. The http verb for the logout method - @see: #logout_method
      #   8. The path to the page showing the user she's unauthorized - @see: #unauthorized_path
      #
      # == Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy.config.auth.user_class = 'Admin'
      #     Alchemy.config.auth.user_class_primary_key = :user_id
      #     Alchemy.config.auth.current_user_method = 'current_admin'
      #     Alchemy.config.auth.signup_path = '/auth/signup'
      #     Alchemy.config.auth.login_path = '/auth/login'
      #     Alchemy.config.auth.logout_path = '/auth/logout'
      #     Alchemy.config.auth.logout_method = 'get'
      #     Alchemy.config.auth.unauthorized_path = '/home'
      #
      # If you don't have your own user model or don't want to provide one,
      # add the `alchemy-devise` gem into your App's Gemfile.
      #
      # == Adding your own CanCan abilities
      #
      # If your app or your engine has own CanCan abilities you must register them:
      #
      #     Alchemy.config.auth.abilities.add("MyCustom::Ability")
      #
      option :user_class_primary_key, :symbol, default: :id
      option :current_user_method, :symbol, default: :current_user
      option :signup_path, :string, default: "/signup"
      option :login_path, :string, default: "/login"
      option :logout_path, :string, default: "/logout"
      option :logout_method, :string, default: "delete"
      option :unauthorized_path, :string, default: "/"
      option :abilities, :collection, item_type: :class

      # Set your App's user class in an initializer.
      #
      # == Example
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy.config.auth.user_class = 'Admin'
      #
      option :user_class, :class

      # Returns the user class name
      #
      # Prefixed with :: when getting to avoid constant name conflicts
      def user_class_name = "::#{raw_user_class}"
    end
  end
end
