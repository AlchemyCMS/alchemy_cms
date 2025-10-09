# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class Tabs < ViewComponent::Base
        erb_template <<~ERB
          <sl-tab-group id="overlay_tabs">
            <% tabs.each do |tab| %>
              <%= render tab.new(@url, is_selected: is_selected?(tab), link_title: @link_title, link_target: @link_target) %>
            <% end %>
          </sl-tab-group>
        ERB

        def initialize(**options)
          options.symbolize_keys!
          @url = options[:url]
          @selected_tab = options[:selected_tab]
          @link_title = options[:link_title]
          @link_target = options[:link_target]
        end

        def is_selected?(tab)
          @selected_tab&.to_sym == tab.panel_name
        end

        def tabs
          Alchemy.config.link_dialog_tabs
        end
      end
    end
  end
end
