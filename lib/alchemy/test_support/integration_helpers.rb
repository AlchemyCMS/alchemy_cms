# frozen_string_literal: true
module Alchemy
  module TestSupport
    # Helpers for integration specs
    #
    # This file is included in spec_helper.rb
    #
    module IntegrationHelpers
      # Used to stub the current_user in integration specs
      #
      # Pass either a user object or a symbol in the format of ':as_admin'.
      #
      def authorize_user(user_or_role = nil)
        case user_or_role
        when Symbol, String
          user = build(:alchemy_dummy_user, user_or_role)
        else
          user = user_or_role
        end
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end
    end
  end
end
