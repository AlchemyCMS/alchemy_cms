module Alchemy
  module Admin
    class ElementSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      attr_reader :elements, :field_name, :autofocus

      def initialize(elements, field_name: "element[name]", autofocus: false)
        @field_name = field_name
        @elements = elements
        @autofocus = autofocus
      end

      def call
        content_tag "alchemy-element-select",
          options: elements_options.to_json,
          placeholder: Alchemy.t(:select_element) do
          text_field_tag(field_name, nil, {
            autofocus:,
            required: true,
            value: elements.many? ? nil : elements.first&.name,
            class: "alchemy_selectbox full_width"
          })
        end
      end

      private

      def elements_options
        return [] if elements.nil?

        elements.sort_by(&:name).map do |element|
          {
            text: Element.display_name_for(element.name),
            hint: element.hint,
            icon: element.icon_file,
            id: element.name
          }
        end
      end
    end
  end
end
