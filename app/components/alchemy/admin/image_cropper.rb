module Alchemy
  module Admin
    class ImageCropper < ViewComponent::Base
      attr_reader :croppable, :picture, :crop_from, :crop_size

      erb_template <<~ERB
        <cropper-canvas background>
          <cropper-image src="<%= src %>" style="width: <%= cropper_settings.image_width %>px; height: <%= cropper_settings.image_height %>px"></cropper-image>
          <cropper-shade></cropper-shade>
          <cropper-handle action="select"></cropper-handle>
          <% if selection %>
            <cropper-selection x="<%= selection[:x] %>" y="<%= selection[:y] %>" width="<%= selection[:width] %>" height="<%= selection[:height] %>" movable resizable>
              <cropper-grid role="grid" covered></cropper-grid>
              <cropper-crosshair centered></cropper-crosshair>
              <cropper-handle action="move"></cropper-handle>
              <cropper-handle action="n-resize"></cropper-handle>
              <cropper-handle action="e-resize"></cropper-handle>
              <cropper-handle action="s-resize"></cropper-handle>
              <cropper-handle action="w-resize"></cropper-handle>
              <cropper-handle action="ne-resize"></cropper-handle>
              <cropper-handle action="nw-resize"></cropper-handle>
              <cropper-handle action="se-resize"></cropper-handle>
              <cropper-handle action="sw-resize"></cropper-handle>
            </cropper-selection>
          <% end %>
        </cropper-canvas>
      ERB

      def initialize(croppable, crop_from: nil, crop_size: nil)
        @croppable = croppable
        @picture = croppable.picture
        @crop_from = crop_from.split("x").map(&:to_i) if crop_from.is_a?(String)
        @crop_size = crop_size.split("x").map(&:to_i) if crop_from.is_a?(String)
      end

      def src
        picture.url(flatten: true)
      end

      def selection
        if crop_from.present? && crop_size.present?
          {
            x: crop_from[0],
            y: crop_from[1],
            width: crop_size[0],
            height: crop_size[1]
          }
        else
          {
            x: cropper_settings.default_box[0],
            y: cropper_settings.default_box[1],
            width: cropper_settings.default_box[2],
            height: cropper_settings.default_box[3]
          }
        end
      end

      private

      def cropper_settings
        croppable.image_cropper_settings
      end
    end
  end
end
