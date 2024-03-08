module Alchemy
  module Ingredients
    class HeadlineView < BaseView
      def initialize(ingredient, level: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @level = level
      end

      def call
        content_tag tag_name, id: dom_id, class: css_classes do
          ingredient.value
        end.html_safe
      end

      private

      def tag_name = "h#{@level || ingredient.level}"

      def dom_id = ingredient.dom_id.presence

      def css_classes
        [
          ingredient.size ? "h#{ingredient.size}" : nil,
          html_options[:class]
        ]
      end
    end
  end
end
