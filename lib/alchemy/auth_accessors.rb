# frozen_string_literal: true

module Alchemy
  class << self
    def user_class_primary_key=(key)
      config.auth.user_class_primary_key = key
    end
    deprecate :user_class_primary_key= => "Use `Alchemy.config.auth.user_class_primary_key instead", :deprecator => Alchemy::Deprecation

    def current_user_method
      config.auth.current_user_method
    end
    deprecate current_user_method: "Use `Alchemy.config.auth.current_user_method instead", deprecator: Alchemy::Deprecation
    def current_user_method=(method)
      config.auth.current_user_method = method
    end
    deprecate :current_user_method= => "Use `Alchemy.config.auth.current_user_method instead", :deprecator => Alchemy::Deprecation

    def signup_path
      config.auth.signup_path
    end
    deprecate signup_path: "Use `Alchemy.config.auth.signup_path instead", deprecator: Alchemy::Deprecation
    def signup_path=(path)
      config.auth.signup_path = path
    end
    deprecate :signup_path= => "Use `Alchemy.config.auth.signup_path instead", :deprecator => Alchemy::Deprecation

    def login_path
      config.auth.login_path
    end
    deprecate login_path: "Use `Alchemy.config.auth.login_path instead", deprecator: Alchemy::Deprecation
    def login_path=(path)
      config.auth.login_path = path
    end
    deprecate :login_path= => "Use `Alchemy.config.auth.login_path instead", :deprecator => Alchemy::Deprecation

    def logout_path
      config.auth.logout_path
    end
    deprecate logout_path: "Use `Alchemy.config.auth.logout_path instead", deprecator: Alchemy::Deprecation
    def logout_path=(path)
      config.auth.logout_path = path
    end
    deprecate :logout_path= => "Use `Alchemy.config.auth.logout_path instead", :deprecator => Alchemy::Deprecation

    def logout_method
      config.auth.logout_method
    end
    deprecate logout_method: "Use `Alchemy.config.auth.logout_method instead", deprecator: Alchemy::Deprecation
    def logout_method=(method)
      config.auth.logout_method = method
    end
    deprecate :logout_method= => "Use `Alchemy.config.auth.logout_method instead", :deprecator => Alchemy::Deprecation

    def unauthorized_path
      config.auth.unauthorized_path
    end
    deprecate unauthorized_path: "Use `Alchemy.config.auth.unauthorized_path instead", deprecator: Alchemy::Deprecation
    def unauthorized_path=(path)
      config.auth.unauthorized_path = path
    end
    deprecate :unauthorized_path= => "Use `Alchemy.config.auth.unauthorized_path instead", :deprecator => Alchemy::Deprecation

    def user_class_name=(class_name)
      config.auth.user_class = class_name
    end
    deprecate :user_class_name= => "Use `Alchemy.config.auth.user_class instead", :deprecator => Alchemy::Deprecation

    def register_ability(klass)
      config.auth.abilities.add(klass.name)
    end
    deprecate register_ability: 'Use `Alchemy.config.auth.abilities.add("MyClass")` instead', deprecator: Alchemy::Deprecation

    def registered_abilities
      config.auth.abilities
    end
    deprecate registered_abilities: "Use `Alchemy.config.abilities` instead", deprecator: Alchemy::Deprecation
  end
end
