# frozen_string_literal: true

module Alchemy
  module Admin
    module Resource
      # Renders a resource table with columns and buttons
      #
      # == Example
      #
      #   <%= render Alchemy::Admin::Resource::Table.new(@languages, query: @query) do |table| %>
      #     <% table.icon_column "translate-2", style: false %>
      #     <% table.column :name, sortable: true %>
      #     <% table.column :language_code, sortable: true %>
      #     <% table.column :page_layout do |language| %>
      #       <%= Alchemy::Page.human_layout_name(language.page_layout) %>
      #     <% end %>
      #     <% table.delete_button %>
      #     <% table.edit_button %>
      #   <% end %>
      #
      # @param [ActiveRecord::Relation] :collection
      #   a collection of Alchemy::Resource objects that are shown in the table
      # @param [Ransack::Search] :query
      #   The ransack search object to allow sortable table columns
      # @param [String] :nothing_found_label (Alchemy.t("Nothing found"))
      #   The message that will be shown, if the collection is empty
      # @param [Hash] :search_filter_params ({})
      #   An additional hash that will attached to the delete and edit button to redirect back to
      #   the same page of the table
      # @param [String] :icon (nil)
      #   a default icon, if the table is auto generated
      class Table < ViewComponent::Base
        delegate :can?,
          :sort_link,
          :render_attribute,
          :resource_path,
          :render_icon,
          :edit_resource_path,
          :resource_handler,
          :resource_window_size,
          to: :helpers

        attr_reader :buttons,
          :columns,
          :collection,
          :query,
          :nothing_found_label,
          :search_filter_params

        erb_template <<~ERB
          <% if collection.any? %>
            <table class="list">
              <thead>
                <tr>
                  <% columns.each do |column| %>
                    <th class="<%= column.css_classes %>">
                      <% if column.sortable %>
                        <%= sort_link query,
                            column.name,
                            column.label,
                            default_order: column.type.to_s =~ /date|time/ ? 'desc' : 'asc' %>
                      <% else %>
                        <%= column.label %>
                      <% end %>
                    </th>
                  <% end %>
                  <% if buttons.present? %>
                    <th class="tools"></th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <% collection.each do |row| %>
                  <tr class="<%= cycle('even', 'odd') %>">
                    <% columns.each do |column| %>
                      <td class="<%= column.css_classes %>">
                        <%= view_context.capture(row, &column.block) %>
                      </td>
                    <% end %>
                    <% if buttons.present? %>
                      <td class="tools">
                        <% buttons.each do |button| %>
                          <% if button.name.nil? || can?(button.name, row) %>
                            <% if button.tooltip.present? %>
                              <sl-tooltip content="<%= button.tooltip %>">
                                <%= view_context.capture(row, &button.block) %>
                              </sl-tooltip>
                            <% else %>
                              <%= view_context.capture(row, &button.block) %>
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
            <alchemy-message type="info">
              <%= nothing_found_label %>
            </alchemy-message>
          <% end %>
        ERB

        def initialize(collection, query: nil, nothing_found_label: Alchemy.t("Nothing found"), search_filter_params: {}, icon: nil)
          @collection = collection
          @query = query
          @nothing_found_label = nothing_found_label
          @search_filter_params = search_filter_params
          @columns = []
          @buttons = []
          @icon = icon
        end

        def column(name, label: nil, sortable: false, type: nil, class_name: nil, &block)
          label ||= resource_handler.model.human_attribute_name(name)
          type ||= resource_handler.model.columns_hash[name.to_s]&.type
          attribute = resource_handler.attributes.find { |item| item[:name] == name.to_s } || {name: name, type: type}
          block ||= lambda { |item| render_attribute(item, attribute) }

          @columns << Attribute.new(name, label: label, sortable: sortable, type: type, alignment: class_name, &block)
        end

        def icon_column(icon = nil, style: nil)
          @columns << Attribute.new(:icon, label: "") do |row|
            render_icon(icon || yield(row), size: "xl", style: style)
          end
        end

        def button(name = nil, tooltip: nil, &block)
          @buttons << Button.new(name, tooltip: tooltip, &block)
        end

        def delete_button(tooltip: Alchemy.t("Delete"), message: Alchemy.t("Are you sure?"))
          button(:destroy, tooltip: tooltip) do |row|
            helpers.delete_button(resource_path(row, search_filter_params), {message: message})
          end
        end

        def edit_button(tooltip: Alchemy.t("Edit"), title: Alchemy.t("Edit"), size: resource_window_size)
          button(:edit, tooltip: tooltip) do |row|
            helpers.link_to_dialog render_icon(:edit),
              edit_resource_path(row, search_filter_params),
              {
                title: title,
                size: size
              },
              class: "icon_button"
          end
        end

        private

        ##
        # the before_render - method is necessary to force ViewComponent to evaluate the column - calls
        # if no columns or buttons are available the resource_helper will be used, to generate the
        # default attributes of the given resource
        def before_render
          content
          if columns.empty? && buttons.empty?
            icon_column(@icon) if @icon.present?
            resource_handler.sorted_attributes.each do |attribute|
              column(attribute[:name], sortable: true)
            end
            delete_button
            edit_button
          end
        end

        class Attribute
          attr_reader :block, :label, :name, :sortable, :type, :css_classes

          def initialize(name, sortable: false, label: nil, type: :string, alignment: nil, &block)
            @name = name
            @label = label || name
            @sortable = sortable
            @block = block
            @type = type
            @css_classes = [name, type, alignment].compact.join(" ")
          end
        end

        class Button
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
