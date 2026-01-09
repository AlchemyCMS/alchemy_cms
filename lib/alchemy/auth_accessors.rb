# frozen_string_literal: true

module Alchemy
  class << self
    delegate :user_class_primary_key, to: :config
    deprecate user_class_primary_key: "Use `Alchemy.config.user_class_primary_key instead", deprecator: Alchemy::Deprecation

    delegate :user_class_primary_key=, to: :config
    deprecate :user_class_primary_key= => "Use `Alchemy.config.user_class_primary_key instead", :deprecator => Alchemy::Deprecation

    delegate :current_user_method, to: :config
    deprecate current_user_method: "Use `Alchemy.config.current_user_method instead", deprecator: Alchemy::Deprecation

    delegate :current_user_method=, to: :config
    deprecate :current_user_method= => "Use `Alchemy.config.current_user_method instead", :deprecator => Alchemy::Deprecation

    delegate :signup_path, to: :config
    deprecate signup_path: "Use `Alchemy.config.signup_path instead", deprecator: Alchemy::Deprecation

    delegate :signup_path=, to: :config
    deprecate :signup_path= => "Use `Alchemy.config.signup_path instead", :deprecator => Alchemy::Deprecation

    delegate :login_path, to: :config
    deprecate login_path: "Use `Alchemy.config.login_path instead", deprecator: Alchemy::Deprecation

    delegate :login_path=, to: :config
    deprecate :login_path= => "Use `Alchemy.config.login_path instead", :deprecator => Alchemy::Deprecation

    delegate :logout_path, to: :config
    deprecate logout_path: "Use `Alchemy.config.logout_path instead", deprecator: Alchemy::Deprecation

    delegate :logout_path=, to: :config
    deprecate :logout_path= => "Use `Alchemy.config.logout_path instead", :deprecator => Alchemy::Deprecation

    delegate :logout_method, to: :config
    deprecate logout_method: "Use `Alchemy.config.logout_method instead", deprecator: Alchemy::Deprecation

    delegate :logout_method=, to: :config
    deprecate :logout_method= => "Use `Alchemy.config.logout_method instead", :deprecator => Alchemy::Deprecation

    delegate :unauthorized_path, to: :config
    deprecate unauthorized_path: "Use `Alchemy.config.unauthorized_path instead", deprecator: Alchemy::Deprecation

    delegate :unauthorized_path=, to: :config
    deprecate :unauthorized_path= => "Use `Alchemy.config.unauthorized_path instead", :deprecator => Alchemy::Deprecation

    delegate :user_class, to: :config
    deprecate user_class: "Use `Alchemy.config.user_class instead", deprecator: Alchemy::Deprecation

    delegate :user_class_name, to: :config
    deprecate user_class_name: "Use `Alchemy.config.user_class_name instead", deprecator: Alchemy::Deprecation

    def user_class_name=(klass_name)
      config.user_class = klass_name
    end
    deprecate :user_class_name= => "Use `Alchemy.config.user_class instead", :deprecator => Alchemy::Deprecation

    def register_ability(klass)
      config.abilities.add(klass.name)
    end
    deprecate register_ability: 'Use `Alchemy.config.abilities.add("MyClass")` instead', deprecator: Alchemy::Deprecation

    def registered_abilities
      config.abilities
    end
    deprecate registered_abilities: "Use `Alchemy.config.abilities` instead", deprecator: Alchemy::Deprecation
  end
end
