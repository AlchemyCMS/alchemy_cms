# frozen_string_literal: true

module Alchemy
  module Admin
    module Pages
      class AnchorTab < BaseLinkTab
        def title
          Alchemy.t("link_overlay_tab_label.anchor")
        end

        def type
          :anchor
        end

        def fields
          [
            anchor_select,
            title_input
          ]
        end

        def message
          content_tag("h3", Alchemy.t(:anchor_link_headline))
        end

        private

        def anchor_select
          label = label_tag("anchor_link", Alchemy.t(:anchor), class: "control-label")
          select = select_tag(:anchor_link,
            options_for_select([[Alchemy.t("Please choose"), ""]]),
            is: "alchemy-select")
          content_tag("div", label + select, class: "input select")
        end
      end
    end
  end
end
