# frozen_string_literal: true

module Alchemy::AbilityHelper
  # Ensures usage of Alchemy's permissions class.
  #
  # == Register custom Abilities
  #
  # If your app has a CanCan Ability class with rules you want to be aviable in an Alchemy context
  # you need to register it. Or if you have an engine with it's own CanCan abilities you want to
  # add to Alchemy you must register them first.
  #
  #     Alchemy.register_ability MyCustom::Permisson
  #
  def current_ability
    @current_ability ||= begin
      alchemy_permissions = Alchemy::Permissions.new(current_alchemy_user)
      Alchemy.registered_abilities.each do |klass|
        # Ensure to avoid issues with Rails constant lookup.
        klass = "::#{klass}".constantize
        alchemy_permissions.merge(klass.new(current_alchemy_user))
      end
      alchemy_permissions
    end
  end
end
