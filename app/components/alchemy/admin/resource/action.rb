# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      # Renders a container for a button, which evaluate CanCanCan and shows a tooltip. This
      # is an internal component for the resource table, to make easier to read.
      #
      # @param [String, Symbol, nil] :name
      #   name of an action to evaluate if the user can perform these action on the given object
      # @param [String, nil] :tooltip
      #   show a tooltip around the button
      # @param [Lambda] :block
      #   a block to include a button or a link
      #
      class Action < ViewComponent::Base
        delegate :can?, to: :helpers

        attr_reader :block, :name, :tooltip

        erb_template <<~ERB
          <% if name.nil? || can?(name, @resource) %>
            <% if tooltip.present? %>
              <wa-tooltip for="<%= button_id %>">
                <%= tooltip %>
              </wa-tooltip>
              <%= view_context.capture(@resource, &block) %>
            <% else %>
              <%= view_context.capture(@resource, &block) %>
            <% end %>
          <% end %>
        ERB

        def initialize(name = nil, tooltip = nil, &block)
          @name = name
          @tooltip = tooltip
          @block = block
        end

        def with_resource(resource)
          @resource = resource
          self
        end

        private

        def button_id
          "#{name}-#{@resource.class.name.underscore}-#{@resource.id}"
        end
      end
    end
  end
end
