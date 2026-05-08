module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class Sites < ViewComponent::Base
          delegate :alchemy, :multi_site?, to: :helpers
          attr_reader :user

          def initialize(user:)
            @user = user
          end

          def render? = multi_site?
          def sites = Site.all
        end
      end
    end
  end
end
