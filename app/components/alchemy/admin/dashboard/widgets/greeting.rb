module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class Greeting < ViewComponent::Base
          def initialize(user:)
            @user = user
            if user.respond_to?(:sign_in_count) && user.respond_to?(:last_sign_in_at)
              @last_sign_at = user.last_sign_in_at
              @first_time = user.sign_in_count == 1 && @last_sign_at.nil?
            end
          end

          def render?
            @user.present?
          end
        end
      end
    end
  end
end
