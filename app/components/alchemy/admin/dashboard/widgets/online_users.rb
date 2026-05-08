module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class OnlineUsers < ViewComponent::Base
          def initialize(user:)
            @user = user
            if Alchemy.config.user_class.respond_to?(:logged_in)
              @online_users = Alchemy.config.user_class.logged_in.to_a - [@user]
            end
          end

          def render? = Alchemy.config.user_class.respond_to?(:logged_in)
        end
      end
    end
  end
end
