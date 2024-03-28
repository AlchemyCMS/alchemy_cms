# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class ExternalTab < BaseTab
        def title
          Alchemy.t("link_overlay_tab_label.external")
        end

        def self.panel_name
          :external
        end

        def fields
          [
            url_input,
            title_input,
            target_select
          ]
        end

        def message
          main_message = content_tag("h3", Alchemy.t(:enter_external_link)) +
            content_tag("p", Alchemy.t(:external_link_notice_1)) +
            content_tag("p", Alchemy.t(:external_link_notice_2))

          render_message(:info, main_message) +
            content_tag("div", content_tag("ul"), id: "errors", class: "errors")
        end

        private

        def url_input
          label = label_tag("external_link", "URL", class: "control-label")
          input = text_field_tag "external_link", is_selected? ? @url : ""
          content_tag("div", label + input, class: "input text")
        end
      end
    end
  end
end
