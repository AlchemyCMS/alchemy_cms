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
        text_field_tag(field_name, nil, {
          "data-options": elements_options.to_json,
          "data-placeholder": Alchemy.t(:select_element),
          is: "alchemy-element-select",
          autofocus: true,
          required: true,
          value: elements.many? ? nil : elements.first&.name
        })
      end

      private

      def elements_options
        return [] if elements.nil?

        elements.sort_by(&:name).map do |element|
          {
            text: Element.display_name_for(element.name),
            icon: element.icon_file,
            id: element.name
          }
        end
      end
    end
  end
end
