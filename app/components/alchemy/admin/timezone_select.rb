module Alchemy
  module Admin
    # Renders a timezone select dropdown triggered by an icon button.
    class TimezoneSelect < ViewComponent::Base
      def call
        tag.div(class: "alchemy-timezone-select") do
          content_tag("sl-tooltip", content: current_timezone, placement: "left") do
            content_tag("sl-dropdown", distance: 5) do
              safe_join([trigger_button, popover_content])
            end
          end
        end
      end

      private

      def trigger_button
        content_tag("sl-button", slot: "trigger", size: "small", variant: "text") do
          content_tag("alchemy-icon", nil, name: "time-zone", size: "1x", slot: "prefix", style: "color: var(--icon-color)")
        end
      end

      def popover_content
        content_tag(:div, class: "alchemy-popover") do
          form_tag(helpers.url_for, method: :get, class: "timezone-select") do
            label_tag(:admin_timezone, Alchemy.t(:timezone)) +
              content_tag("alchemy-auto-submit") do
                select_tag(
                  :admin_timezone,
                  options_for_select(timezones_for_select, current_timezone)
                )
              end
          end
        end
      end

      def timezones_for_select
        ActiveSupport::TimeZone.all.map(&:name)
      end

      def current_timezone
        Time.zone.name
      end
    end
  end
end
