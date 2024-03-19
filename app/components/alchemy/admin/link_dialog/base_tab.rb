# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class BaseTab < ViewComponent::Base
        include BaseHelper

        erb_template <<~ERB
          <sl-tab slot="nav" panel="<%= panel_name %>"><%= title %></sl-tab>
          <sl-tab-panel name="<%= panel_name %>">
            <form data-link-form-type="<%= name %>">
              <%= message %>
              <% fields.each do |field| %>
                <%= field %>
              <% end %>
              <div class="submit">
                <%= button_tag(Alchemy.t(:apply)) %>
              </div>
            </form>
          </sl-tab-panel>
        ERB

        def initialize(url)
          @url = url
        end

        def title
          raise ArgumentError, "The tab needs to have a title"
        end

        def name
          raise ArgumentError, "The tab needs to have a name"
        end

        def fields
          []
        end

        def message
          ""
        end

        private

        def panel_name
          "overlay_tab_#{name}_link"
        end

        def title_input
          input_name = "#{name}_link_title"
          label = label_tag(input_name, Alchemy.t(:link_title), class: "control-label")
          input = text_field_tag input_name, "", class: "link_title"
          content_tag("div", label + input, class: "input text")
        end

        def target_select
          select_name = "#{name}_link_target"
          label = label_tag(select_name, Alchemy.t("Open Link in"), class: "control-label")
          select = select_tag(select_name, options_for_select(Alchemy::Page.link_target_options, @target), class: "link_target")
          content_tag("div", label + select, class: "input select")
        end
      end
    end
  end
end
