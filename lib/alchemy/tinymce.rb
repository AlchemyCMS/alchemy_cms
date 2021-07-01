# frozen_string_literal: true

module Alchemy
  module Tinymce
    mattr_accessor :languages, :plugins

    @@plugins = %w(alchemy_link anchor autoresize charmap code directionality fullscreen hr link lists paste tabfocus table)
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
        "pastetext charmap hr | undo redo | alchemy_link unlink anchor | code",
      ],
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: "raw",
      paste_as_text: true,
      element_format: "html",
      branding: false,
    }

    class << self
      def init=(settings)
        @@init.merge!(settings)
      end

      def init
        @@init
      end

      def custom_config_contents(page)
        content_definitions_from_elements(page.descendent_element_definitions)
      end

      def custom_config_ingredients(page)
        ingredient_definitions_from_elements(page.descendent_element_definitions)
      end

      private

      def content_definitions_from_elements(definitions)
        definitions.collect do |el|
          next if el["contents"].blank?

          contents = el["contents"].select do |c|
            c["settings"] && c["settings"]["tinymce"].is_a?(Hash)
          end
          next if contents.blank?

          contents.map { |c| c.merge("element" => el["name"]) }
        end.flatten.compact
      end

      def ingredient_definitions_from_elements(definitions)
        definitions.collect do |el|
          next if el["ingredients"].blank?

          ingredients = el["ingredients"].select do |c|
            c["settings"] && c["settings"]["tinymce"].is_a?(Hash)
          end
          next if ingredients.blank?

          ingredients.map { |c| c.merge("element" => el["name"]) }
        end.flatten.compact
      end
    end
  end
end
