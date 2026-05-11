module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class OnlineUsers < ViewComponent::Base
          delegate :current_alchemy_user, to: :helpers

          private

          def online_users
            if Alchemy.config.user_class.respond_to?(:logged_in)
              Alchemy.config.user_class.logged_in.to_a - [current_alchemy_user]
            end
          end
        end
      end
    end
  end
end
