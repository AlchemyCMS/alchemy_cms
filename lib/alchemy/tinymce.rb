# frozen_string_literal: true

module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    DEFAULT_PLUGINS = %w[
      anchor
      charmap
      code
      directionality
      fullscreen
      link
      lists
    ]

    @@plugins = DEFAULT_PLUGINS + %w[alchemy_link]
    @@init = {
      skin: "alchemy",
      content_css: "/assets/tinymce/skins/content/alchemy/content.min.css",
      icons: "remixicons",
      width: "auto",
      resize: true,
      min_height: 250,
      height: 250,
      menubar: false,
      statusbar: true,
      toolbar: [
        "bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen",
        "pastetext charmap hr | undo redo | alchemy_link unlink anchor | code"
      ],
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: "raw",
      paste_as_text: true,
      element_format: "html",
      branding: false
    }

    class << self
      def init=(settings)
        @@init.merge!(settings)
      end

      def init
        @@init
      end

      def preloadable_plugins
        @@plugins
      end
    end
  end
end
