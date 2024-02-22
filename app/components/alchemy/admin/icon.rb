module Alchemy
  module Admin
    # Render a Remix icon
    #
    class Icon < ViewComponent::Base
      attr_reader :icon_name, :style, :size, :css_class

      # @param icon_name [String] icon name
      # @option options - style: fill [String] icon style. line or fill. Pass false for no style.
      # @option options - size: nil [String] icon size
      # @option options - class: nil [String] css class
      def initialize(icon_name, options = {})
        @icon_name = icon_name
        @style = options[:style].nil? ? "line" : options[:style]
        @size = options[:size]
        @css_class = options[:class]
      end

      def call
        content_tag("alchemy-icon", nil, name: ri_icon, size: size, "icon-style": ri_style, class: css_class)
      end

      private

      # Returns the Remix icon name for given icon name
      #
      # @return [String] The Remix icon class
      def ri_icon
        case icon_name.to_s
        when "minus", "remove", "delete"
          "delete-bin-2"
        when "plus"
          "add"
        when "copy"
          "file-copy"
        when "download"
          "download-2"
        when "upload"
          "upload-2"
        when "exclamation"
          "alert"
        when "info-circle", "info"
          "information"
        when "times"
          "close"
        when "tag"
          "price-tag-3"
        when "cog"
          "settings-3"
        else
          icon_name
        end
      end

      # Returns the Remix icon style for given style
      #
      # @return [String] The RemixIcon style
      def ri_style
        return "none" if style == false

        case style.to_s
        when "solid", "fill"
          "fill"
        when "line", "regular"
          "line"
        else
          style
        end
      end
    end
  end
end
