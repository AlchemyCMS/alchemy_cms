module Alchemy
  module Admin
    module Dashboard
      module Widgets
        # Reusable stat card component for dashboard
        #
        class StatCard < ViewComponent::Base
          erb_template <<-ERB
            <div class="dashboard-stat-card">
              <div class="stat-card-title"><%= title %></div>
              <div class="stat-card-subtitle"><%== subtitle || '&nbsp;' %></div>

              <div class="stat-card-content">
                <% if icon %>
                  <div class="stat-card-icon">
                    <%= render_icon(icon, size: "xl", style: icon_style) %>
                  </div>
                <% end %>

                <div class="stat-card-value">
                  <%= link_to_if link.present?, value, link %>
                </div>
              </div>
            </div>
          ERB

          attr_reader :title, :value, :icon, :icon_style, :subtitle, :link
          delegate :render_icon, to: :helpers

          # @param title: Card title/label
          # @param value: The main statistic value to display
          # @param icon: (optional) Icon name from Remix Icon set
          # @param subtitle: (optional) Additional context text
          # @param link: (optional) Hash with :url and :text for action link
          def initialize(title:, value:, icon: nil, icon_style: "line", subtitle: nil, link: nil)
            @title = title
            @value = value
            @icon = icon
            @icon_style = icon_style
            @subtitle = subtitle
            @link = link
          end
        end
      end
    end
  end
end
