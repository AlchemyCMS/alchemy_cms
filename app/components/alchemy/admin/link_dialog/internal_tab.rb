# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class InternalTab < BaseTab
        PAGE_URL_PATTERN = /\A\/(?<locale>[a-z]{2})?(?<slash>\/)?(?<urlname>.*?)(?<trailing-slash>\/)?\z/

        def title
          Alchemy.t("link_overlay_tab_label.internal")
        end

        def self.panel_name
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

        ##
        # transform url into a URI object
        #
        # encode the uri and parse it again to prevent exceptions if the Url is in the wrong format
        # @return [URI,nil]
        def uri
          @_uri ||= @url ? URI(@url.strip) : nil
        end

        def page
          @_page ||= if uri&.path == "/"
            Alchemy::Current.site.default_language.root_page
          elsif uri
            Alchemy::Page.find_by(page_attributes)
          end
        end

        def page_attributes
          locale, _, urlname, _ = uri.path.match(PAGE_URL_PATTERN)&.captures

          if locale && urlname.present?
            {language_code: locale, urlname: urlname}
          elsif locale
            {language_code: locale, language_root: true}
          else
            {urlname: urlname}
          end
        end

        def page_select
          label = label_tag("internal_link", Alchemy.t(:page), class: "control-label")
          input = text_field_tag("internal_link", page && uri, id: "internal_link")
          page_select = render Alchemy::Admin::PageSelect.new(page, allow_clear: true).with_content(input)
          content_tag("div", label + page_select, class: "input select")
        end

        def dom_id_select
          fragment = "##{uri.fragment}" if uri&.fragment
          label = label_tag("element_anchor", Alchemy.t(:anchor), class: "control-label")
          options = [[page.nil? ? Alchemy.t("Select a page first") : Alchemy.t("None"), ""]]
          options += [[fragment, fragment]] if page && fragment

          select = select_tag("element_anchor", options_for_select(options, fragment), is: "alchemy-select", disabled: page.nil?)
          select_component = content_tag("alchemy-dom-id-api-select", select, {page: page&.id})

          content_tag("div", label + select_component, class: "input select")
        end
      end
    end
  end
end
