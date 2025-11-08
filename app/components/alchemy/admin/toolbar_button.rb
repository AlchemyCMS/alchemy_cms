module Alchemy
  module Admin
    # Renders a toolbar button for the Alchemy toolbar
    #
    # == Example
    #
    #   <%= render Alchemy::Admin::ToolbarButton.new(
    #     url: new_resource_path,
    #     icon: :plus,
    #     label: 'Create Resource',
    #     hotkey: 'alt+n',
    #     dialog_options: {
    #       title: 'Create Resource',
    #       size: "430x400"
    #     },
    #     if_permitted_to: [:create, resource_model]
    #   ) %>
    #
    # @param [String] :url
    #   Url for link.
    # @param [String] :icon
    #   Icon name. See https://remixicon.com for available icons.
    # @param [String] :label
    #   Text for button tooltip.
    # @param [String] :hotkey
    #   Keyboard shortcut for this button. I.E +alt-n+
    # @param [Hash] :dialog_options
    #   Overlay options. See link_to_dialog helper.
    # @param [Array] :if_permitted_to ([:action, :controller])
    #   Check permission for button. Exactly how you defined the permission in your +authorization_rules.rb+. Defaults to controller and action from button url.
    # @param [Boolean] :skip_permission_check (false)
    #   Skip the permission check. NOT RECOMMENDED!
    #
    class ToolbarButton < ViewComponent::Base
      erb_template <<-ERB
        <wa-tooltip for="<%= id %>" placement="<%= tooltip_placement %>">
          <%= label %>
        </wa-tooltip>
        <div class="toolbar_button" id="<%= id %>">
          <%= link_to(render_icon(icon, style: icon_style), url, {
            class: css_classes,
            "data-dialog-options" => dialog ? dialog_options.to_json : nil,
            "data-alchemy-hotkey" => hotkey,
            :is => dialog ? "alchemy-dialog-link" : nil
          }.merge(link_options)) %>
        </div>
      ERB

      delegate :can?, :link_to, :link_to_dialog, :render_icon, to: :helpers

      attr_reader :url,
        :icon,
        :label,
        :hotkey,
        :dialog,
        :dialog_options,
        :skip_permission_check,
        :if_permitted_to,
        :active,
        :link_options,
        :id,
        :icon_style,
        :tooltip_placement

      def initialize(
        url:,
        icon:,
        label:,
        hotkey: nil,
        title: nil,
        dialog: true,
        dialog_options: {},
        skip_permission_check: false,
        if_permitted_to: [],
        active: false,
        link_options: {},
        id: nil,
        icon_style: "line",
        tooltip_placement: "top-start"
      )
        @url = url
        @icon = icon
        @label = label
        @hotkey = hotkey
        @dialog = dialog
        @dialog_options = dialog_options
        @skip_permission_check = skip_permission_check
        @if_permitted_to = if_permitted_to
        @active = active
        @link_options = link_options
        @id = id || "toolbar-button-#{SecureRandom.hex(4)}"
        @icon_style = icon_style
        @tooltip_placement = tooltip_placement
      end

      def render?
        skip_permission_check || can?(*permission_options)
      end

      private

      def css_classes = ["icon_button", active && "active"].compact

      def permission_options = if_permitted_to.presence || permissions_from_url

      def permissions_from_url
        action_controller = url.delete_prefix("/").split("/")
        [
          action_controller.last.to_sym,
          action_controller[0..action_controller.length - 2].join("_").to_sym
        ]
      end
    end
  end
end
