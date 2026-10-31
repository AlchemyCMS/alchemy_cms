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

        # Entries without a position that were inserted between Alchemy's own
        # entries are listed after the positioned entry preceding them, so
        # +Alchemy.config.menu.insert+ can replace the deprecated position.
        # Appended entries without a position are listed last.
        def items
          menu = Alchemy.config.menu.to_a
          core_names = Alchemy::Configurations::Menu::DEFAULT.map { |entry| entry[:name] }
          last_core_index = menu.rindex { |item| core_names.include?(item.name) } || -1
          preceding_position = 0
          menu.each_with_index.map do |item, index|
            preceding_position = item.position if item.position
            key = if item.position
              [item.position, 0, index]
            elsif index < last_core_index
              [preceding_position, 1, index]
            else
              [Float::INFINITY, 0, index]
            end
            [item, key]
          end.sort_by(&:last).map(&:first)
        end
      end
    end
  end
end
