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
      alchemy_link
    ]

    SKINS = %w[alchemy alchemy-dark]

    @@plugins = DEFAULT_PLUGINS
    @@init = {
      skin: "alchemy",
      icons: "remixicons",
      width: "auto",
      resize: true,
      min_height: 250,
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
      branding: false,
      license_key: "gpl"
    }

    class << self
      def init=(settings)
        @@init.merge!(settings)
      end

      def init
        @@init
      end

      def preloadable_plugins
        @@plugins - DEFAULT_PLUGINS
      end

      # Query string TinyMCE appends to every asset it loads at runtime.
      #
      # TinyMCE loads these from undigested asset paths that are served with a
      # one year immutable cache, so they need a content dependent query string
      # to ever be fetched again. The asset pipeline digests all of them
      # individually, but TinyMCE only takes a single suffix for all of them.
      def cache_suffix(view_context)
        digested_paths = undigested_assets.map { |path| view_context.asset_path(path) }
        ActiveSupport::Digest.hexdigest(digested_paths.join).first(8)
      end

      private

      def undigested_assets
        SKINS.flat_map do |skin|
          [
            "tinymce/skins/ui/#{skin}/skin.min.css",
            "tinymce/skins/ui/#{skin}/content.min.css",
            "tinymce/skins/content/#{skin}/content.min.css"
          ]
        end + preloadable_plugins.map { |plugin| "tinymce/plugins/#{plugin}/plugin.min.js" }
      end
    end
  end
end
