# frozen_string_literal: true

module Alchemy
  module Admin
    # The current user at the bottom of the main menu, opening a menu with the
    # user's name, the timezone and the admin locale.
    class UserMenu < ViewComponent::Base
      erb_template <<~ERB
        <alchemy-user-menu class="user-menu">
          <sl-dropdown placement="right-end" distance="6" hoist>
            <button type="button" slot="trigger" class="user-menu-trigger">
              <span class="user-avatar">
                <% if initial %>
                  <%= initial %>
                <% else %>
                  <alchemy-icon name="user" size="1x"></alchemy-icon>
                <% end %>
              </span>
              <span class="user-menu-label">
                <span class="user-menu-name"><%= display_name %></span>
                <span class="user-menu-meta"><%= Time.zone.name %> · <%= ::I18n.locale.to_s.upcase %></span>
              </span>
              <alchemy-icon name="arrow-right-s" size="1x"></alchemy-icon>
            </button>
            <div class="alchemy-popover user-menu-panel">
              <%= render Alchemy::Admin::CurrentUserName.new(user:) %>
              <%= render Alchemy::Admin::TimezoneSelect.new(inline: true) %>
              <% if locale_select.render? %>
                <div class="user-menu-locale">
                  <%= label_tag(:admin_locale, Alchemy.t(:language)) %>
                  <%= render locale_select %>
                </div>
              <% end %>
            </div>
          </sl-dropdown>
        </alchemy-user-menu>
      ERB

      attr_reader :user

      def initialize(user:)
        @user = user
      end

      def render?
        user.present?
      end

      private

      def display_name
        user.try(:alchemy_display_name).to_s
      end

      def initial
        display_name.strip.first.presence&.upcase
      end

      def locale_select
        @_locale_select ||= Alchemy::Admin::LocaleSelect.new
      end
    end
  end
end
