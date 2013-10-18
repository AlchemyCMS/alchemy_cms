module Alchemy
  module TestSupport

    # Helpers for authentication
    #
    module AuthHelpers

      def sign_in(user = admin_user)
        controller.stub current_alchemy_user: user
      end

      def member_user
        mock_user([:member])
      end

      def author_user
        mock_user([:author])
      end

      def editor_user
        mock_user([:editor])
      end

      def admin_user
        mock_user([:admin])
      end

      def mock_user(roles)
        mock_model(Alchemy.user_class, alchemy_roles: roles.map(&:to_sym))
      end

    end

  end
end
