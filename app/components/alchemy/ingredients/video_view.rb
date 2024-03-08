module Alchemy
  module Ingredients
    class VideoView < BaseView
      delegate :attachment, to: :ingredient

      def call
        content_tag(:video, html_options) do
          tag(:source, src: src, type: attachment.file_mime_type)
        end.html_safe
      end

      def render?
        !attachment.nil?
      end

      private

      def src
        alchemy.show_attachment_path(
          attachment,
          format: attachment.suffix
        )
      end

      def html_options
        {
          controls: ingredient.controls,
          autoplay: ingredient.autoplay,
          loop: ingredient.loop,
          muted: ingredient.muted,
          playsinline: ingredient.playsinline,
          preload: ingredient.preload.presence,
          width: ingredient.width.presence,
          height: ingredient.height.presence
        }.merge(@html_options)
      end
    end
  end
end
