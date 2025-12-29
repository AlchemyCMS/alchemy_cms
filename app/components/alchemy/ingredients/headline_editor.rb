# frozen_string_literal: true

module Alchemy
  module Ingredients
    class HeadlineEditor < BaseEditor
      delegate :level, :levels, :size, :sizes, to: :ingredient

      def input_field(form)
        tag.div(class: "input-field") do
          concat form.text_field(:value,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            required: presence_validation?,
            pattern: format_validation,
            id: form_field_id)

          if settings[:anchor]
            concat render(
              "alchemy/ingredients/shared/anchor",
              ingredient_editor: ingredient
            )
          end

          concat(
            tag.div(class: ["input-addon", "right", has_size_select? ? "second" : nil].compact) do
              content_tag("sl-tooltip", content: form.object.class.human_attribute_name(:level)) do
                form.select(
                  :level,
                  options_for_select(level_options, level),
                  {},
                  class: "custom-select",
                  disabled: !has_level_select?
                )
              end
            end
          )

          if has_size_select?
            concat(
              tag.div(class: "input-addon right") do
                content_tag("sl-tooltip", content: form.object.class.human_attribute_name(:size)) do
                  form.select(
                    :size,
                    options_for_select(size_options, size),
                    {},
                    class: "custom-select"
                  )
                end
              end
            )
          end
        end
      end

      private

      def css_classes
        super + [
          has_level_select? ? "with-level-select" : nil,
          has_size_select? ? "with-size-select" : nil
        ].compact
      end

      def level_options
        levels.map { |level| ["H#{level}", level] }
      end

      def size_options
        sizes.map do |size|
          case size
          when Array
            size
          else
            [".h#{size}", size]
          end
        end
      end

      def has_level_select? = level_options.many?
      def has_size_select? = size_options.many?
    end
  end
end
