# frozen_string_literal: true

module Alchemy
  module Admin
    module MainNavigation
      class Entry < ViewComponent::Base
        erb_template <<~ERB
          <%= content_tag :"alchemy-main-navi-entry", class: css_classes, data: data_attributes do %>
            <%= link_to item.path(helpers) do %>
              <% if item.image %>
                <%= image_tag(item.image) %>
              <% elsif item.inline_image %>
                <%== item.inline_image %>
              <% elsif item.icon %>
                <%= content_tag :"alchemy-icon", nil,
                  name: item.icon,
                  "icon-style": item.icon_style %>
              <% else %>
                <%= render_icon :table %>
              <% end %>
              <label><%= Alchemy.t(item.title) %></label>
            <% end %>
            <%= render Alchemy::Admin::MainNavigation::SubNavigation.new(item) %>
          <% end %>
        ERB

        with_collection_parameter :item

        delegate :render_icon, to: :helpers

        attr_reader :item

        def initialize(item:)
          @item = item
        end

        def before_render
          item.validate_controller_existence!
        end

        def render?
          item.visible?(helpers)
        end

        private

        def css_classes
          [
            "main_navi_entry",
            ("active" if item.active?(helpers)),
            ("has_sub_navigation" if item.children.any?)
          ].compact
        end

        def data_attributes
          {turbo: false} unless item.turbo
        end
      end
    end
  end
end
