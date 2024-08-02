# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      # Renders a table header tag
      # the component is an internal component of the Table component
      #
      # @param [String] :name
      #   name of the sortable link or the text if not additional text is given
      # @param [String] :query
      #   Ransack query
      # @param [String] :css_classes ("")
      #   css class of the th - tag
      # @param [String, nil] :text (nil)
      #  optional text of the header
      # @param [Symbol] :type (:string)
      #  type of the column will be used to inverse the sorting order for data/time - objects
      # @param [Boolean] :sortable (false)
      #  enable a sortable link
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
          @query = query
          @text = text || name
          @css_classes = css_classes
          @default_order = /date|time/.match?(type.to_s) ? "desc" : "asc"
          @sortable = sortable
        end
      end
    end
  end
end
