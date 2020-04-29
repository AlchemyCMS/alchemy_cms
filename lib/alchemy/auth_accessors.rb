# frozen_string_literal: true

# Provides authentication accessors.
#
# Alchemy has some defaults for user model name and login logout path names:
#
# +Alchemy.user_class_name+ defaults to +'User'+
# +Alchemy.user_class_primary_key+ defaults to +:id+
# +Alchemy.current_user_method defaults to +'current_user'+
# +Alchemy.signup_path defaults to +'/signup'+
# +Alchemy.login_path defaults to +'/login'+
# +Alchemy.logout_path defaults to +'/logout'+
# +Alchemy.logout_method defaults to +'delete'+
#
# Anyway, you can tell Alchemy about your authentication model configuration:
#
#   1. Your user class name - @see: Alchemy.user_class
#   2. Your users table primary key - @see: Alchemy.user_class_primary_key
#   3. A method on your ApplicationController to get current user -
#      @see: Alchemy.current_user_method
#   4. The path to the signup form - @see: Alchemy.signup_path
#   5. The path to the login form - @see: Alchemy.login_path
#   6. The path to the logout method - @see: Alchemy.logout_path
#   7. The http verb for the logout method - @see: Alchemy.logout_method
#
# == Example
#
#     # config/initializers/alchemy.rb
#     Alchemy.user_class_name = 'Admin'
#     Alchemy.user_class_primary_key = :user_id
#     Alchemy.current_user_method = 'current_admin'
#     Alchemy.signup_path = '/auth/signup'
#     Alchemy.login_path = '/auth/login'
#     Alchemy.logout_path = '/auth/logout'
#     Alchemy.logout_method = 'get'
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
  mattr_accessor :user_class_primary_key,
    :current_user_method,
    :signup_path,
    :login_path,
    :logout_path,
    :logout_method

  # Defaults
  #
  @@user_class_name = "User"
  @@user_class_primary_key = :id
  @@current_user_method = "current_user"
  @@signup_path = "/signup"
  @@login_path = "/login"
  @@logout_path = "/logout"
  @@logout_method = "delete"

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

  # Prefix with :: when getting to avoid constant name conflicts
  def self.user_class_name
    if !@@user_class_name.is_a?(String)
      raise TypeError, "Alchemy.user_class_name must be a String, not a Class."
    end

    "::#{@@user_class_name}"
  end

  def self.user_class_name=(user_class_name)
    @@user_class_name = user_class_name
  end

  def self.user_class
    @@user_class ||= begin
      @@user_class_name.constantize
    rescue NameError => e
      if e.message =~ /#{Regexp.escape(@@user_class_name)}/
        abort <<-MSG.strip_heredoc

        AlchemyCMS cannot find any user class!

        Please add a user class and tell Alchemy about it or, if you don't want
        to create your own class, add the `alchemy-devise` gem to your Gemfile.

            bundle add alchemy-devise

        MSG
      else
        raise e
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
