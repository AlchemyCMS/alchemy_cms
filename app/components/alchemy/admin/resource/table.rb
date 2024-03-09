# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      class Table < ViewComponent::Base
        include BaseHelper
        delegate :can?, :sort_link, :render_attribute, to: :helpers

        attr_reader :actions, :columns, :collection, :ransack_query, :resource_url, :nothing_found_label

        erb_template <<~ERB
          <% if collection.any? %>
            <table class="list">
              <thead>
                <tr>
                  <% columns.each do |column| %>
                    <th class="<%= column.name %>">
                        <% if column.sortable %>
                          <%= sort_link [resource_url, ransack_query],
                              column.name,
                              column.label,
                              default_order: column.type.to_s =~ /date|time/ ? 'desc' : 'asc' %>
                        <% else %>
                          <%= column.label %>
                        <% end %>
                    </th>
                  <% end %>
                  <% if actions.present? %>
                    <th class="tools"></th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <% collection.each do |row| %>
                  <tr class="<%= cycle('even', 'odd') %>">
                    <% columns.each do |column| %>
                      <td class="<%= column.type %> <%= column.name %>">
                        <%= view_context.capture(row, &column.block) %>
                      </td>
                    <% end %>
                    <% if actions.present? %>
                      <td class="tools">
                        <% actions.each do |action| %>
                          <% if action.name.nil? || can?(action.name, row) %>
                            <% if action.tooltip.present? %>
                              <sl-tooltip content="<%= action.tooltip %>">
                                <%= view_context.capture(row, &action.block) %>
                              </sl-tooltip>
                            <% else %>
                              <%= view_context.capture(row, &action.block) %>
                            <% end %>
                          <% end %>
                        <% end %>
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

        def initialize(collection, ransack_query: nil, nothing_found_label: Alchemy.t("Nothing found"), resource_url: :resource_url_proxy)
          @collection = collection
          @ransack_query = ransack_query
          @nothing_found_label = nothing_found_label
          @resource_url = resource_url
          @columns = []
          @actions = []
        end

        def column(name, label: nil, sortable: false, type: :string, &block)
          @columns << Column.new(name, label: label, sortable: sortable, type: type, &block)
        end

        def icon_column(icon = nil)
          @columns << Column.new(:icon, label: "") do |row|
            render_icon(icon || yield(row), size: "xl")
          end
        end

        def action(name = nil, tooltip: nil, &block)
          @actions << Action.new(name, tooltip: tooltip, &block)
        end

        private

        ##
        # the before_render - method is necessary to force ViewComponent to evaluate the add_column - calls
        def before_render
          content
        end

        class Column
          attr_reader :block, :label, :name, :sortable, :type

          def initialize(name, sortable: false, label: nil, type: :string, &block)
            @name = name
            @label = label || name
            @sortable = sortable
            @block = block || lambda { |item| transform item[name] }
            @type = type
          end

          private

          def transform(value)
            case value
            when DateTime, ActiveSupport::TimeWithZone
              ::I18n.l(value, format: :"alchemy.default")
            when Time
              ::I18n.l(value, format: :"alchemy.time")
            else
              value
            end
          end
        end

        class Action
          attr_reader :name, :tooltip, :block

          def initialize(name = nil, tooltip: nil, &block)
            @name = name
            @tooltip = tooltip
            @block = block
          end
        end
      end
    end
  end
end
