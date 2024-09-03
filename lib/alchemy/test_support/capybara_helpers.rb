# frozen_string_literal: true

module Alchemy
  module TestSupport
    module CapybaraHelpers
      # Select2 capybara helper
      def select2(value, options)
        label = find_label_by_text(options[:from])

        select2_anchor_selector = ".select2-container a"

        if label.has_css?(select2_anchor_selector)
          label.find(select2_anchor_selector).click
        else
          within label.find(:xpath, "..") do
            find(select2_anchor_selector).click
          end
        end

        within_entire_page do
          page.find(
            "div.select2-result-label",
            text: /#{Regexp.escape(value)}/i, match: :prefer_exact
          ).click
        end
      end

      def select2_search(value, options)
        if options[:from]
          label = find_label_by_text(options[:from])
          within label.first(:xpath, ".//..") do
            options[:from] = "##{find(".select2-container")["id"]}"
          end
        elsif options[:element_id] && options[:ingredient_role]
          container_id = find("#element_#{options[:element_id]} [data-ingredient-role='#{options[:ingredient_role]}'] .select2-container")["id"]
          options[:from] = "##{container_id}"
        end

        find("#{options[:from]}:not(.select2-container-disabled):not(.select2-offscreen)").click

        within_entire_page do
          find("input.select2-input.select2-focused").set(value)
          expect(page).to_not have_selector(".select2-searching")
          unless options[:select] == false
            expect(page).to have_selector(".select2-result-label", visible: true)
            find("div.select2-result-label", text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
            expect(page).not_to have_selector(".select2-result-label")
          end
        end
      end

      def click_button_with_tooltip(content)
        find(%([content="#{content}"] button)).click
      end

      def click_link_with_tooltip(content)
        find(%([content="#{content}"] > a)).click
      end

      def click_icon(name)
        find(%(alchemy-icon[name="#{name}"])).click
      end

      private

      def within_entire_page(&)
        within(:xpath, "//body", &)
      end

      def find_label_by_text(text)
        find "label:not(.select2-offscreen)",
          text: /#{Regexp.escape(text)}/i,
          match: :one
      rescue Capybara::ElementNotFound
        find %([content="#{text}"]), match: :one
      end
    end
  end
end
