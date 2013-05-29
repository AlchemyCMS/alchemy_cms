module Alchemy
  module Specs

    # Helpers for controller specs
    #
    # This file is included in rspec controller tests.
    #
    module ControllerHelpers

      def sign_in(user=admin_user)
        request.env['warden'].stub :authenticate! => user
        request.env['warden'].set_user(user, store: false, run_callbacks: false)
        controller.stub :current_user => user
      end

      def admin_user
        mock_user([:admin])
      end

      def registered_user
        mock_user([:registered])
      end

      def mock_user(roles)
        mock_model(User,
          name: 'Hermes Trismegistus',
          roles: roles.map(&:to_sym),
          store_request_time!: nil
        )
      end

    end

  end
end
