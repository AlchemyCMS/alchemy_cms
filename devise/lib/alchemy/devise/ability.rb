module Alchemy
  module Devise
    class Ability
      include CanCan::Ability

      def initialize(user)
        @user = user

        can :signup, Alchemy::User
        can :create, Alchemy::User if Alchemy::User.count == 0

        if member? || author? || editor?
          can [:show, :update], Alchemy.user_class, id: user.id
        end

        if editor? || admin?
          can :index, :alchemy_admin_users
          can :read, Alchemy.user_class
        end

        if admin?
          can :manage, Alchemy.user_class
        end
      end

      private

      def member?
        @user.try(:has_role?, :member)
      end

      def author?
        @user.try(:has_role?, :author)
      end

      def editor?
        @user.try(:has_role?, :editor)
      end

      def admin?
        @user.try(:has_role?, :admin)
      end
    end
  end
end
