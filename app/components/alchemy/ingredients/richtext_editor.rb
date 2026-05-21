# frozen_string_literal: true

module Alchemy
  module Ingredients
    class RichtextEditor < BaseEditor
      UnknownRichtextEditor = Class.new(ArgumentError)

      Alchemy.config.richtext_editors.each do |editor|
        include(editor)
      end

      def input_field
        editor = settings[:editor] || Alchemy.config.default_richtext_editor
        if available_editors.include?(editor.to_s.downcase)
          send("#{editor}_editor")
        else
          raise UnknownRichtextEditor, "Unknown richtext editor: #{settings[:editor]}"
        end
      end

      private

      def available_editors
        Alchemy.config.richtext_editors.map { _1.to_s.demodulize.downcase }
      end

      def editor_text_area
        text_area_tag form_field_name,
          value,
          minlength: length_validation&.fetch(:minimum, nil),
          maxlength: length_validation&.fetch(:maximum, nil),
          id: form_field_id(:value),
          hidden: true
      end
    end
  end
end
