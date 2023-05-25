module Alchemy
  module Ingredients
    class HeadlineView < BaseView
      def initialize(ingredient, level: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @level = level
      end

      def call
        content_tag "h#{@level || ingredient.level}",
          ingredient.value,
          id: ingredient.dom_id.presence,
          class: [
            ingredient.size ? "h#{ingredient.size}" : nil,
            html_options[:class]
          ]
      end
    end
  end
end
