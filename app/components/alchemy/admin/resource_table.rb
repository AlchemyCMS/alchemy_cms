# frozen_string_literal: true

module Alchemy
  module Admin
    class ResourceTable < ViewComponent::Base
      include BaseHelper

      attr_reader :columns, :collection, :nothing_found_label

      erb_template <<~ERB
        <% if collection.any? %>
          <table class="list">
            <thead>
              <tr>
                <% columns.each do |column| %>
                  <th><%= column.label || column.name %></th>
                <% end %>
              </tr>
            </thead>
            <tbody>
              <% collection.each do |row| %>
                <tr class="<%= cycle('even', 'odd') %>">
                  <% columns.each do |column| %>
                    <td class="<%= column.name %>">
                      <%= view_context.capture(row, &column.block) %>
                    </td>
                  <% end %>
                </tr>
              <% end %>
            </tbody>
          </table>
        <% else %>
          <div class="info">
            <%= render_icon('info') %>
            <%= nothing_found_label %>
          </div>
        <% end %>
      ERB

      def initialize(collection, nothing_found_label: Alchemy.t("Nothing found"))
        @collection = collection
        @nothing_found_label = nothing_found_label
        @columns = []
      end

      def add_column(name, label: nil, sortable: true, &block)
        @columns << Column.new(name, label: label, sortable: sortable, &block)
      end

      private

      ##
      # the before_render - method is necessary to force ViewComponent to evaluate the add_column - calls
      def before_render
        content
      end

      class Column
        attr_reader :block, :label, :name, :sortable

        def initialize(name, sortable:, label: nil, &block)
          @name = name
          @label = label
          @sortable = sortable
          @block = block || lambda { |item| item[name] }
        end
      end
    end
  end
end
