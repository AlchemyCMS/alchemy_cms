# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class Tabs < ViewComponent::Base
        erb_template <<~ERB
          <sl-tab-group id="overlay_tabs">
            <% tabs.each do |tab| %>
              <%= render tab.new %>
            <% end %>
          </sl-tab-group>
        ERB

        def tabs
          Alchemy.link_dialog_tabs
        end
      end
    end
  end
end
