# frozen_string_literal: true

module Alchemy
  module Admin
    module Pages
      class ExternalTab < BaseLinkTab
        def title
          Alchemy.t("link_overlay_tab_label.external")
        end

        def type
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
          content_tag("h3", Alchemy.t(:enter_external_link)) +
            content_tag("p", Alchemy.t(:external_link_notice_1)) +
            content_tag("p", Alchemy.t(:external_link_notice_2))
        end

        private

        def url_input
          label = label_tag("external_link", Alchemy.t(:url), class: "control-label")
          input = text_field_tag "external_link", tab_selected? ? @url : ""
          content_tag("div", label + input, class: "input text")
        end
      end
    end
  end
end
