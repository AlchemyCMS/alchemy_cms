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
            dom_id_select,
            title_input
          ]
        end

        def message
          render_message(:info, content_tag("p", Alchemy.t(:anchor_link_headline)))
        end

        private

        def dom_id_select
          label = label_tag("anchor_link", Alchemy.t(:anchor), class: "control-label")
          options = [[Alchemy.t("None"), ""]]
          options += [[@url, @url]] if is_selected? && @url

          select = select_tag(:anchor_link, options_for_select(options, @url), is: "alchemy-select")
          select_component = content_tag("alchemy-dom-id-preview-select", select)

          content_tag("div", label + select_component, class: "input select")
        end
      end
    end
  end
end
