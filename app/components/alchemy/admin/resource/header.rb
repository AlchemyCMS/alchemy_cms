# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      # Renders a container for a button, which evaluate CanCanCan and shows a tooltip. This
      # is an internal component for the resource table, to make easier to read.
      #
      # @param [String] :name
      #   name of an action to evaluate if the user can perform these action on the given object
      # @param [String, nil] :tooltip
      #   show a tooltip around the button
      # @param [Lambda] :block
      #   a block to include a button or a link
      #
      class Header < ViewComponent::Base
        delegate :sort_link, to: :helpers

        erb_template <<~ERB
          <th class="<%= @css_classes %>">
            <% if @sortable %>
              <%= sort_link @query, @name, @label, default_order: @default_order %>
            <% else %>
              <%= @label %>
            <% end %>
          </th>
        ERB

        def initialize(name, query, css_classes: "", label: nil, type: :string, sortable: false)
          @name = name
          @label = label || name
          @query = query
          @css_classes = css_classes
          @default_order = /date|time/.match?(type.to_s) ? "desc" : "asc"
          @sortable = sortable
        end
      end
    end
  end
end
