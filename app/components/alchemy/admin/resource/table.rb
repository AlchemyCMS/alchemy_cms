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
        delegate :render_attribute,
          :resource_path,
          :render_icon,
          :edit_resource_path,
          :resource_handler,
          :resource_window_size,
          to: :helpers

        attr_reader :collection,
          :nothing_found_label,
          :search_filter_params

        renders_many :headers, Header

        renders_many :cells, ->(css_classes, &block) do
          Cell.new(css_classes, &block)
        end

        renders_many :actions, ->(name, tooltip = nil, &block) do
          Action.new(name, tooltip, &block)
        end

        erb_template <<~ERB
          <% if collection.any? %>
            <table class="list">
              <thead>
                <tr>
                  <% headers.each do |header| %>
                    <%= header %>
                  <% end %>
                  <% if actions? %>
                    <th class="tools"></th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <% collection.each do |resource| %>
                  <tr class="<%= cycle('even', 'odd') %>">
                    <% cells.each do |cell| %>
                       <%= render cell.with_resource(resource) %>
                    <% end %>
                    <% if actions? %>
                      <td class="tools">
                        <% actions.each do |action| %>
                          <%= render action.with_resource(resource) %>
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
          @icon = icon
        end

        def column(name, header: nil, sortable: false, type: nil, class_name: nil, &block)
          header ||= resource_handler.model.human_attribute_name(name)
          type ||= resource_handler.model.columns_hash[name.to_s]&.type
          attribute = resource_handler.attributes.find { |item| item[:name] == name.to_s } || {name: name, type: type}
          block ||= lambda { |item| render_attribute(item, attribute) }

          css_classes = [name, type, class_name].compact.join(" ")
          with_header(name, @query, css_classes: css_classes, text: header, type: type, sortable: sortable)
          with_cell(css_classes, &block)
        end

        def icon_column(icon = nil, style: nil)
          column(:icon, header: "") do |resource|
            render_icon(icon || yield(resource), size: "xl", style: style)
          end
        end

        def delete_button(tooltip: Alchemy.t("Delete"), confirm_message: Alchemy.t("Are you sure?"))
          with_action(:destroy, tooltip) do |row|
            helpers.delete_button(resource_path(row, search_filter_params), {message: confirm_message})
          end
        end

        def edit_button(tooltip: Alchemy.t("Edit"), dialog_title: tooltip, dialog_size: resource_window_size)
          with_action(:edit, tooltip) do |row|
            helpers.link_to_dialog render_icon(:edit),
              edit_resource_path(row, search_filter_params),
              {
                size: dialog_size,
                title: dialog_title
              },
              class: "icon_button"
          end
        end

        private

        ##
        # if no cells are available the resource_helper will be used, to generate the
        # default attributes of the given resource
        def before_render
          unless cells?
            icon_column(@icon) if @icon.present?
            resource_handler.sorted_attributes.each do |attribute|
              column(attribute[:name], sortable: true)
            end
            delete_button
            edit_button
          end
        end
      end
    end
  end
end
