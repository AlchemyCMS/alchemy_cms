module Alchemy
  module Ingredients
    class FileView < BaseView
      delegate :attachment, to: :ingredient

      # @param ingredient [Alchemy::Ingredient]
      # @param link_text [String] The link text. If not given, the ingredients link_text setting or the attachments name will be used.
      # @param html_options [Hash] Options that will be passed to the a tag.
      def initialize(ingredient, link_text: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @link_text = settings_value(:link_text, value: link_text, default: attachment&.name)
      end

      def call
        link_to(
          link_text,
          attachment.url(
            download: true,
            name: attachment.slug,
            format: attachment.suffix
          ),
          {
            class: ingredient.css_class.presence,
            title: ingredient.title.presence
          }.merge(html_options)
        )
      end

      def render?
        !attachment.nil?
      end

      private

      def link_text
        ingredient.link_text.presence || @link_text
      end
    end
  end
end
