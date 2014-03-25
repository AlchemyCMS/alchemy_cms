# Provides authentication accessors.
#
# Alchemy has some defaults for user model name and login logout path names:
#
# +Alchemy.user_class_name+ defaults to +'User'+
# +Alchemy.login_path defaults to +'/login'+
# +Alchemy.logout_path defaults to +'/logout'+
#
# Anyway, you can tell Alchemy about your authentication model configuration:
#
#   1. Your user class name - @see: Alchemy.user_class
#   2. The path to the login form - @see: Alchemy.login_path
#   3. The path to the logout method - @see: Alchemy.logout_path
#
# == Example
#
#     # config/initializers/alchemy.rb
#     Alchemy.user_class_name = 'Admin'
#     Alchemy.login_path = '/auth/login'
#     Alchemy.logout_path = '/auth/logout'
#
# If you don't have your own user model or don't want to provide one,
# add the `alchemy-devise` gem into your App's Gemfile.
#
# == Adding your own CanCan abilities
#
# If your app or your engine has own CanCan abilities you must register them:
#
#     Alchemy.register_ability MyCustom::Ability
#
module Alchemy
  mattr_accessor :user_class_name, :current_user_method, :login_path, :logout_path

  # Defaults
  #
  @@user_class_name = 'User'
  @@current_user_method = 'current_user'
  @@login_path = '/login'
  @@logout_path = '/logout'

  # Returns the user class
  #
  # Set your App's user class to Alchemy.user_class_name in an initializer.
  #
  # Defaults to +User+
  #
  # == Example
  #
  #     # config/initializers/alchemy.rb
  #     Alchemy.user_class_name = 'Admin'
  #
  def self.user_class
    @@user_class ||= begin
      if @@user_class_name.is_a?(String)
        @@user_class_name.constantize
      else
        raise 'Alchemy.user_class_name must be a String, not a Class.'
      end
    end
  end

  # Register a CanCan Ability class
  #
  def self.register_ability(klass)
    @abilities ||= []
    @abilities << klass
  end

  # All CanCan Ability classes registered to Alchemy
  #
  def self.registered_abilities
    @abilities ||= []
  end

end
