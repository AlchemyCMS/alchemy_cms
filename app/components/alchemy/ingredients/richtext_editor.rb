# frozen_string_literal: true

module Alchemy
  module Ingredients
    class RichtextEditor < BaseEditor
      include Alchemy::RichtextEditor::Tiptap
      include Alchemy::RichtextEditor::Tinymce

      def input_field
        if settings[:editor] == "tiptap"
          tiptap_editor
        else
          tinymce_editor
        end
      end

      private

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
