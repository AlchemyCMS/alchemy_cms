module Alchemy
  module Specs

    # Helpers for controller specs
    #
    # This file is included in rspec controller tests.
    #
    module ControllerHelpers

      def sign_in(user = admin_user)
        controller.stub current_alchemy_user: user
      end

      def admin_user
        mock_user([:admin])
      end

      def member_user
        mock_user([:member])
      end

      def mock_user(roles)
        mock_model(Alchemy.user_class, alchemy_roles: roles.map(&:to_sym))
      end

    end

  end
end
