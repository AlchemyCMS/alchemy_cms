module Alchemy
  module Admin
    class PageNode < ViewComponent::Base
      with_collection_parameter :page

      attr_reader :page

      delegate :alchemy,
        :current_alchemy_user,
        :can?,
        :render_icon,
        :link_to_dialog,
        :link_to_confirm_dialog,
        :page_layout_missing_warning,
        to: :helpers

      def initialize(page:)
        @page = page
      end
    end
  end
end
