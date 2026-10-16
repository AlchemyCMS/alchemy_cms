# frozen_string_literal: true

module Alchemy
  module Admin
    module MainNavigation
      class Menu < ViewComponent::Base
        erb_template <<~ERB
          <div id="main_navi">
            <%= render Alchemy::Admin::MainNavigation::Entry.with_collection(items) %>
            <%= helpers.content_for(:alchemy_main_navigation) %>
          </div>
        ERB

        def items
          positioned, unpositioned = Alchemy.config.menu.partition(&:position)
          positioned.sort_by(&:position) + unpositioned
        end
      end
    end
  end
end
