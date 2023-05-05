module Alchemy
  module Ingredients
    class LinkView < BaseView
      attr_reader :text

      # @param ingredient [Alchemy::Ingredient]
      # @param text [String] The link text. If not given, the ingredient's text setting or the value will be used.
      # @param html_options [Hash] Options that will be passed to the a tag.
      def initialize(ingredient, text: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @text = text
      end

      def call
        link_to(link_text, value, {target: link_target}.merge(html_options))
      end

      def render?
        value.present?
      end

      private

      def link_text
        text || ingredient.settings[:text] || value
      end

      def link_target
        (ingredient.link_target == "blank") ? "_blank" : nil
      end
    end
  end
end
