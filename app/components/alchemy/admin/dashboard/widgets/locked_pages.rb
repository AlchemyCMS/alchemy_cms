module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class LockedPages < ViewComponent::Base
          delegate :alchemy, :can?, :render_icon, :multi_site?,
            to: :helpers

          def initialize(user:, style: "default")
            @user = user
            @style = style
            @all_locked_pages = Page.locked
          end

          private

          def colspan = multi_site? ? 5 : 4
        end
      end
    end
  end
end
