# frozen_string_literal: true

module Alchemy
  module Ingredients
    class SelectEditor < BaseEditor
      def input_field
        if select_values.nil?
          warning(":select_values is nil",
            <<-MSG.strip_heredoc
              <strong>No select values given.</strong>
              <br>Please provide <code>select_values</code> on the
              ingredient definition <code>settings</code> in
              <code>elements.yml</code>.
            MSG
          )
        else
          options_tags = if select_values.is_a?(Hash)
            grouped_options_for_select(select_values, value)
          else
            options_for_select(select_values, value)
          end
          select_tag form_field_name, options_tags, {
            id: form_field_id,
            class: ["ingredient-editor-select"],
            is: "alchemy-select"
          }
        end
      end

      private

      def select_values = settings[:select_values]
    end
  end
end
