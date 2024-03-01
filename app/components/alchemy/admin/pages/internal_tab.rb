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
            anchor_select,
            title_input,
            target_select
          ]
        end

        def message
          content_tag("h3", Alchemy.t(:internal_link_headline)) +
            content_tag("p", Alchemy.t(:internal_link_page_elements_explanation))
        end

        private

        ##
        # transform url into a URI object
        #
        # encode the uri and parse it again to prevent exceptions if the Url is in the wrong format
        # @return [URI|nil]
        def uri
          @_uri ||= @url ? URI(@url.strip) : nil
        end

        def page
          @_page ||= uri ? Alchemy::Page.find_by(urlname: uri.path[1..]) : nil
        end

        def anchor_select
          fragment = uri.fragment if uri
          label = label_tag("element_anchor", Alchemy.t(:anchor), class: "control-label")
          options = [[Alchemy.t("Please choose"), ""]]
          options += [["##{fragment}", fragment]] if tab_selected? && fragment

          select = select_tag("element_anchor", options_for_select(options, fragment), is: "alchemy-select")
          select_component = content_tag("alchemy-anchor-select", select, {page: page&.id})

          content_tag("div", label + select_component, class: "input select")
        end

        def page_select
          label = label_tag("internal_link", Alchemy.t(:page), class: "control-label")
          input = text_field_tag("internal_link", tab_selected? ? uri : "", id: "internal_link")
          page_select = render Alchemy::Admin::PageSelect.new(page, allow_clear: true).with_content(input)
          content_tag("div", label + page_select, class: "input select")
        end
      end
    end
  end
end
