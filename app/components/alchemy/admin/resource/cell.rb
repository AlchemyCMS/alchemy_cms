# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      # Renders a table cell with the given css classes
      #
      # @param [String, nil] :css_classes
      #   css classes that are show at the table cell
      # @param [Object, nil] :resource
      #   the resource of the row the cell belongs to
      # @param [Lambda] :block
      #   a block to include a button or a link
      #
      class Cell < ViewComponent::Base
        attr_reader :block, :css_classes

        erb_template <<~ERB
          <td class="<%= css_classes %>">
            <%= view_context.capture(@resource, &block) %>
          </td>
        ERB

        def initialize(css_classes, resource = nil, &block)
          @css_classes = css_classes
          @resource = resource
          @block = block
        end
      end
    end
  end
end
