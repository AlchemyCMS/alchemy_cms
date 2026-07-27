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
      delegate :cannot?, :link_to, :link_to_dialog, :render_icon, to: :helpers

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
        :tooltip_placement,
        :primary

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
        tooltip_placement: "top-start",
        primary: false
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
        @id = id
        @icon_style = icon_style
        @tooltip_placement = tooltip_placement
        @primary = primary
      end

      def call
        tag.div class: "toolbar_button", id: do
          if primary
            link_tag
          else
            content_tag "sl-tooltip", content: label, placement: tooltip_placement, disabled: disabled? do
              link_tag
            end
          end
        end
      end

      private

      def link_tag
        if disabled?
          tag.a(link_text, class: css_classes, tabindex: "-1")
        else
          link_to link_text, url, {
            :class => css_classes,
            "data-dialog-options" => dialog ? dialog_options.to_json : nil,
            "data-alchemy-hotkey" => hotkey,
            :is => dialog ? "alchemy-dialog-link" : nil
          }.merge(link_options)
        end
      end

      def link_text
        primary ? icon_tag + label : icon_tag
      end

      def icon_tag = render_icon(icon, style: icon_style)

      def disabled?
        @_disabled ||= !skip_permission_check && cannot?(*permission_options)
      end

      def css_classes
        [
          primary ? "button with_icon" : "icon_button",
          disabled? ? "disabled" : nil,
          active ? "active" : nil
        ].compact
      end

      def permission_options = if_permitted_to.presence || permissions_from_url

      def permissions_from_url
        action_controller = url.delete_prefix("/").split("/")
        [
          action_controller.last.to_sym,
          action_controller[0..-2].join("_").to_sym
        ]
      end
    end
  end
end
