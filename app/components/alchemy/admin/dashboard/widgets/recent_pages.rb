module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class RecentPages < ViewComponent::Base
          delegate :alchemy, :current_alchemy_user, :render_icon, :multi_site?, to: :helpers

          private

          def user = current_alchemy_user
          def last_edited_pages = Page.all_last_edited_from(user).limit(5)
        end
      end
    end
  end
end
