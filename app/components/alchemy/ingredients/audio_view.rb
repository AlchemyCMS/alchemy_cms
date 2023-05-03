module Alchemy
  module Ingredients
    class AudioView < BaseView
      def call
        content_tag(:audio, **html_options) do
          tag(:source, src: src, type: type)
        end
      end

      def render?
        !!ingredient.attachment
      end

      private

      def src
        alchemy.show_attachment_path(
          ingredient.attachment,
          format: ingredient.attachment.suffix
        )
      end

      def type
        ingredient.attachment.file_mime_type
      end

      def html_options
        {
          controls: ingredient.controls,
          autoplay: ingredient.autoplay,
          loop: ingredient.loop,
          muted: ingredient.muted
        }
      end
    end
  end
end
