# frozen_string_literal: true

module Alchemy
  module Admin
    module MainNavigation
      class SubNavigation < ViewComponent::Base
        erb_template <<~ERB
          <div class="sub_navigation">
            <% item.children.each do |child| %>
              <% if child.visible?(helpers) %>
                <div class="subnavi_tab<%= " active" if child.active?(helpers) %>">
                  <%= link_to Alchemy.t(child.title), child.path(helpers) %>
                </div>
              <% end %>
            <% end %>
          </div>
        ERB

        attr_reader :item

        def initialize(item)
          @item = item
        end

        def render?
          item.children.any?
        end
      end
    end
  end
end
