# frozen_string_literal: true

module Alchemy
  module Liquid
    module Drops
      # Exposes an Alchemy::Element to Liquid templates.
      #
      #   {{ element.name }}
      #   {{ element.ingredients.headline.value }}
      #   {% for child in element.nested_elements %}...{% endfor %}
      class ElementDrop < Base
        def name
          record.name
        end

        def tag_list
          record.tag_list.map { escape(_1) }
        end

        # The element's ingredients, keyed by role.
        # @return [IngredientsDrop]
        def ingredients
          @ingredients ||= IngredientsDrop.new(record)
        end

        # The element's visible nested elements.
        #
        # Reads from the page version's element repository, like
        # +element_view_for(element).nested_elements+ does in ERB.
        def nested_elements
          @nested_elements ||= record.page_version.element_repository
            .children_of(record).visible.map { ElementDrop.new(_1) }
        end

        def page
          drop(record.page)
        end
      end
    end
  end
end
