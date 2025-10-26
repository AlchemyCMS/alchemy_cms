module Alchemy
  module Admin
    class ElementSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      attr_reader :elements, :field_name

      def initialize(elements, field_name: "element[name]")
        @field_name = field_name
        @elements = elements
      end

      def call
        content_tag "alchemy-element-select",
          options: elements_options.to_json,
          placeholder: Alchemy.t(:select_element) do
          text_field_tag(field_name, nil, {
            autofocus: true,
            required: true,
            value: elements.many? ? nil : elements.first&.name,
            class: "alchemy_selectbox"
          })
        end
      end

      private

      def elements_options
        return [] if elements.nil?

        elements.sort_by(&:name).map do |element|
          {
            name: Element.display_name_for(element.name),
            hint: element.hint,
            icon: element.icon_file,
            id: element.name
          }
        end
      end
    end
  end
end
