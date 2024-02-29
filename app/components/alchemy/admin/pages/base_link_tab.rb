# frozen_string_literal: true

module Alchemy
  module Admin
    module Pages
      class BaseLinkTab < ViewComponent::Base
        include BaseHelper

        def initialize(url, selected_tab, title, target)
          @url = url
          @selected_tab = selected_tab
          @title = title
          @target = target
        end

        def title
          raise ArgumentError, "The tab needs to have a title"
        end

        def type
          raise ArgumentError, "The tab needs to have a panel type"
        end

        def fields
          []
        end

        def message
          nil
        end

        def tab_selected?
          type == @selected_tab&.to_sym
        end

        def call
          content = message ? render_message(:info, message) : ""
          content += content_tag("div", content_tag("ul"), id: "errors", class: "errors")
          content += fields.join("").html_safe + submit_button

          form = content_tag("form", content.html_safe, {"data-link-form-type": type})

          panel_name = "overlay_tab_#{type}_link"
          options = {slot: "nav", panel: panel_name}
          options[:active] = "" if tab_selected?

          content_tag("sl-tab", title, options) +
            content_tag("sl-tab-panel", form, name: panel_name)
        end

        private

        def title_input
          name = "#{type}_link_title"
          label = label_tag(name, Alchemy.t(:link_title), class: "control-label")
          input = text_field_tag name, @title, class: "link_title"
          content_tag("div", label + input, class: "input text")
        end

        def target_select
          name = "#{type}_link_target"
          label = label_tag(name, Alchemy.t("Open Link in"), class: "control-label")
          select = select_tag(name, options_for_select(Alchemy::Page.link_target_options, @target), class: "link_target")
          content_tag("div", label + select, class: "input select")
        end

        def submit_button
          content_tag("div", button_tag(Alchemy.t(:apply)), {class: "submit"})
        end
      end
    end
  end
end
