# frozen_string_literal: true

module Alchemy
  module Admin
    module Pages
      class InternalTab < BaseLinkTab
        def title
          Alchemy.t("link_overlay_tab_label.internal")
        end

        def type
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
          content_tag("h3", Alchemy.t(:internal_link_headline)) +
            content_tag("p", Alchemy.t(:internal_link_page_elements_explanation))
        end

        private

        def page
          @_page ||= @url ? Alchemy::Page.find_by(urlname: URI(@url).path[1..]) : nil
        end

        def dom_id_select
          label = label_tag("element_anchor", Alchemy.t(:anchor), class: "control-label")
          input = text_field_tag("element_anchor", nil, {id: "element_anchor", class: "alchemy_selectbox full_width", disabled: true, placeholder: Alchemy.t("Select a page first")})
          content_tag("div", label + input, class: "input select")
        end

        def page_select
          label = label_tag("internal_link", Alchemy.t(:page), class: "control-label")
          input = text_field_tag("internal_link", tab_selected? ? @url : "", id: "internal_link")
          page_select = render Alchemy::Admin::PageSelect.new(page, allow_clear: true).with_content(input)
          content_tag("div", label + page_select, class: "input select")
        end
      end
    end
  end
end
