# frozen_string_literal: true

module Alchemy
  module Admin
    # Renders the visibility state badges (hidden / scheduled) shown for an
    # element in the element header.
    class ElementStatusIndicators < ViewComponent::Base
      def initialize(element:)
        @element = element
      end

      private

      attr_reader :element

      def scheduled_tooltip
        Alchemy.t(
          element.public_on&.future? ? :public_on : :public_until,
          scope: :element_scheduled,
          public_on: element.public_on && ::I18n.l(element.public_on, format: :"alchemy.default"),
          public_until: element.public_until && ::I18n.l(element.public_until, format: :"alchemy.default")
        )
      end

      def scheduled_label
        date = element.public_on&.future? ? element.public_on : element.public_until
        date && ::I18n.l(date, format: :"alchemy.short_datetime")
      end
    end
  end
end
