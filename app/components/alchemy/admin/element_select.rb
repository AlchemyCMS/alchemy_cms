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
        content_tag "select", element_options,
          is: "alchemy-element-select",
          name: field_name,
          required: true,
          autofocus:,
          placeholder: Alchemy.t(:select_element)
      end

      private

      def element_options
        return "".html_safe if elements.nil?

        # Preselect the only option, so adding a single available element type
        # does not require an explicit selection.
        preselect = !elements.many?

        safe_join(
          elements.sort_by(&:name).map do |element|
            tag.option(
              Element.display_name_for(element.name),
              value: element.name,
              selected: preselect,
              data: {icon: element.icon_file, hint: element.hint}
            )
          end
        )
      end
    end
  end
end
