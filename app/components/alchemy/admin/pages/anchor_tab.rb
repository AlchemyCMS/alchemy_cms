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
          options = [[Alchemy.t("Please choose"), ""]]
          options += [["##{@url}", @url]] if tab_selected? && @url

          select = select_tag(:anchor_link, options_for_select(options, @url), is: "alchemy-select")
          select_component = content_tag("alchemy-anchor-select", select, {type: "preview"})

          content_tag("div", label + select_component, class: "input select")
        end
      end
    end
  end
end
