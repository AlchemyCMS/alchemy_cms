module Alchemy
  module Admin
    class PagePublicationFields < ViewComponent::Base
      def initialize(page:)
        @page = page
      end

      private

      def checkbox
        check_box_tag :page_public, nil,
          @page.public? || @page.scheduled?,
          name: nil,
          disabled: @page.attribute_fixed?(:public_on)
      end
    end
  end
end
