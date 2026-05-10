module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class RecentPages < ViewComponent::Base
          delegate :alchemy, :render_icon, :multi_site?, to: :helpers

          def initialize(user:, style: "default")
            @user = user
            @style = style
            @last_edited_pages = Page.all_last_edited_from(user).limit(5)
          end
        end
      end
    end
  end
end
