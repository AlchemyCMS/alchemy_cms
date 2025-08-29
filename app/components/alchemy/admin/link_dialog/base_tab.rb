# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class BaseTab < ViewComponent::Base
        include BaseHelper

        attr_reader :url, :link_title, :link_target

        erb_template <<~ERB
          <wa-tab slot="nav" panel="overlay_tab_<%= panel_name %>_link"<%= is_selected? ? ' active' : '' %>><%= title %></wa-tab>
          <wa-tab-panel name="overlay_tab_<%= panel_name %>_link">
            <form data-link-form-type="<%= panel_name %>">
              <%= message %>
              <% fields.each do |field| %>
                <%= field %>
              <% end %>
              <div class="submit">
                <%= button_tag(Alchemy.t(:apply)) %>
              </div>
            </form>
          </wa-tab-panel>
        ERB

        def initialize(url, is_selected: false, link_title: "", link_target: nil)
          @url = url
          @is_selected = is_selected
          @link_title = link_title
          @link_target = link_target
        end

        def is_selected?
          @is_selected
        end

        def title
          raise ArgumentError, "The tab needs to have a title"
        end

        def self.panel_name
          raise ArgumentError, "The tab needs to have a panel name"
        end

        def fields
          []
        end

        def message
          ""
        end

        private

        def panel_name
          self.class.panel_name
        end

        def title_input
          input_name = "#{panel_name}_link_title"
          label = label_tag(input_name, Alchemy.t(:link_title), class: "control-label")
          input = text_field_tag input_name, @link_title, class: "link_title"
          content_tag("div", label + input, class: "input text")
        end

        def target_select
          select_name = "#{panel_name}_link_target"
          label = label_tag(select_name, Alchemy.t("Open Link in"), class: "control-label")
          select = select_tag(select_name, options_for_select(Alchemy::Page.link_target_options, @link_target), class: "link_target")
          content_tag("div", label + select, class: "input select")
        end
      end
    end
  end
end
