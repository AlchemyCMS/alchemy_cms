module Alchemy
  module Ingredients
    class HeadlineView < BaseView
      def call
        content_tag "h#{ingredient.level}",
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
