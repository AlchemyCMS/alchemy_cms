module Alchemy
  module Admin
    class PreviewTimeSelect < ViewComponent::Base
      erb_template <<~ERB
        <div id="preview_time_select">
          <div class="select_with_label">
            <sl-tooltip content="<%= tooltip %>" placement="top-start">
              <alchemy-icon name="calendar-schedule"></alchemy-icon>
              <alchemy-auto-submit>
                <form action="<%= url %>" method="get">
                  <%= select_tag("alchemy_preview_time",
                    options_for_select(preview_times, selected),
                    include_blank: Alchemy.t(:now),
                    disabled:) %>
                </form>
              <alchemy-auto-submit>
            </sl-tooltip>
          </div>
          <div class="toolbar_spacer"></div>
        </div>
      ERB

      def initialize(page_version, url:, selected: nil)
        @page_version = page_version
        @url = url
        @selected = selected
        @disabled = preview_times.none?
      end

      private

      attr_reader :page_version, :selected, :url, :disabled

      def preview_times
        @_preview_times ||= begin
          now = Time.current
          elements = page_version.elements
          future_public_on = elements.where("public_on > ?", now).pluck(:public_on)
          future_public_until = elements.where("public_until > ?", now).pluck(:public_until)
          times = (future_public_on | future_public_until)
          times.sort!
          times.map { |time| [l(time, format: :"alchemy.element_date"), time.iso8601] }
        end
      end

      def tooltip
        if disabled
          Alchemy.t(:no_future_publication_dates)
        else
          Alchemy.t(:preview_time)
        end
      end
    end
  end
end
