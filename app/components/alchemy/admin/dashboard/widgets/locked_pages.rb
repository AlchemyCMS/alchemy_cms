module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class LockedPages < ViewComponent::Base
          delegate :alchemy, :can?, :render_icon, :multi_site?,
            to: :helpers

          def initialize(user:)
            @user = user
            @all_locked_pages = Page.locked
          end
        end
      end
    end
  end
end
