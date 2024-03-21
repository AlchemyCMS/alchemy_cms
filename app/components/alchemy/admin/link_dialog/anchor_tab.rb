# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class AnchorTab < BaseTab
        def title
          Alchemy.t("link_overlay_tab_label.anchor")
        end

        def self.panel_name
          :anchor
        end

        def fields
          [
            anchor_select,
            title_input
          ]
        end

        def message
          render_message(:info, content_tag("p", Alchemy.t(:anchor_link_headline)))
        end

        private

        def anchor_select
          label = label_tag("anchor_link", Alchemy.t(:anchor), class: "control-label")
          options = [[Alchemy.t("Please choose"), ""]]
          options += [[@url, @url]] if is_selected? && @url

          select = select_tag(:anchor_link, options_for_select(options, @url), is: "alchemy-select")
          select_component = content_tag("alchemy-anchor-select", select, {type: "preview"})

          content_tag("div", label + select_component, class: "input select")
        end
      end
    end
  end
end
