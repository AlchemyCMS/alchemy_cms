module Alchemy
  module Ingredients
    class LinkView < BaseView
      include LinkTarget

      attr_reader :link_text

      # @param ingredient [Alchemy::Ingredient]
      # @param text [String] The link text. If not given, the ingredient's text setting or the value will be used.
      # @param html_options [Hash] Options that will be passed to the a tag.
      def initialize(ingredient, text: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @link_text = settings_value(:text, value: text, default: value)
      end

      def call
        target = ingredient.link_target.presence
        link_to(link_text, value, {
          target: link_target_value(target),
          rel: link_rel_value(target)
        }.merge(html_options)).html_safe
      end
    end
  end
end
