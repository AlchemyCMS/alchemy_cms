module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class Sites < ViewComponent::Base
          delegate :alchemy, :current_alchemy_user, to: :helpers

          private

          def sites = Site.all
        end
      end
    end
  end
end
