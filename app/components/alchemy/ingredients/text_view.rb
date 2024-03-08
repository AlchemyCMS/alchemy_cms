module Alchemy
  module Ingredients
    class TextView < BaseView
      attr_reader :disable_link

      delegate :dom_id, :link, :link_title, :link_target,
        to: :ingredient

      # @param ingredient [Alchemy::Ingredient]
      # @param disable_link [Boolean] (false) Whether to disable the link even if the picture has a link.
      # @param html_options [Hash] Options that will be passed to the a tag.
      def initialize(ingredient, disable_link: nil, html_options: {})
        super(ingredient, html_options: html_options)
        @disable_link = settings_value(:disable_link, value: disable_link, default: false)
      end

      def call
        if disable_link?
          dom_id.present? ? anchor : value
        else
          link_to(value, url_for(link), {
            id: dom_id.presence,
            title: link_title,
            target: ((link_target == "blank") ? "_blank" : nil),
            data: {link_target: link_target}
          }.merge(html_options))
        end.html_safe
      end

      private

      def anchor
        content_tag(:a, value, {id: dom_id}.merge(html_options))
      end

      def disable_link?
        link.blank? || disable_link
      end
    end
  end
end
