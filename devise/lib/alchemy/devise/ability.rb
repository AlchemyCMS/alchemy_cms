module Alchemy
  module Devise
    class Ability
      include CanCan::Ability

      def initialize(user)
        return if user.nil?
        if user.has_role?(:member) || user.has_role?(:author) || user.has_role?(:editor)
          can [:read, :update], Alchemy.user_class, id: user.id
        end
        if user.has_role?(:editor) || user.has_role?(:admin)
          can :index, [:alchemy_admin_users]
          can :read, Alchemy.user_class
        end
        if user.has_role?(:admin)
          can :manage, Alchemy.user_class
        end
      end

    end
  end
end
