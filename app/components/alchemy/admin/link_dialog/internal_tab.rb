# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class InternalTab < BaseTab
        def title
          Alchemy.t("link_overlay_tab_label.internal")
        end

        def name
          :internal
        end

        def fields
          [
            page_select,
            dom_id_select,
            title_input,
            target_select
          ]
        end

        def message
          main_message = content_tag("h3", Alchemy.t(:internal_link_headline)) +
            content_tag("p", Alchemy.t(:internal_link_page_elements_explanation))
          render_message(:info, main_message)
        end

        private

        def page_select
          label = label_tag("internal_link", Alchemy.t(:page), class: "control-label")
          input = text_field_tag("internal_link", "", id: "internal_link", class: "alchemy_selectbox full_width")
          content_tag("div", label + input, class: "input select")
        end

        def dom_id_select
          label = label_tag("element_anchor", Alchemy.t(:anchor), class: "control-label")
          options = {id: "element_anchor", class: "alchemy_selectbox full_width", disabled: true, placeholder: Alchemy.t("Select a page first")}
          input = text_field_tag("element_anchor", nil, options)
          content_tag("div", label + input, class: "input select")
        end
      end
    end
  end
end
