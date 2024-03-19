# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class Tabs < ViewComponent::Base
        erb_template <<~ERB
          <sl-tab-group id="overlay_tabs">
            <% tabs.each do |tab| %>
              <%= render tab.new(@url) %>
            <% end %>
          </sl-tab-group>
        ERB

        def initialize(url)
          @url = url
        end

        def tabs
          Alchemy.link_dialog_tabs
        end
      end
    end
  end
end
