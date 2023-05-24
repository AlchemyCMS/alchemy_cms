# frozen_string_literal: true

module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    @@plugins = %w[alchemy_link anchor autoresize charmap code directionality fullscreen hr link lists paste tabfocus table]
    @@init = {
      skin: "alchemy",
      width: "auto",
      resize: true,
      autoresize_min_height: "105",
      autoresize_max_height: "480",
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
    end
  end
end
