# frozen_string_literal: true

module Alchemy
  module TestSupport
    module CapybaraHelpers
      # @deprecated Use {#tom_select} instead.
      def select2(value, options)
        Alchemy::Deprecation.warn(
          "Alchemy::TestSupport::CapybaraHelpers#select2 is deprecated. Use #tom_select instead."
        )
        tom_select(value, options)
      end

      # Tom Select capybara helper
      def tom_select(value, options)
        label = find_label_by_text(options[:from])

        within label.find(:xpath, "..") do
          find(".ts-control").click
        end

        # The dropdown is appended to the body, so search the whole page for it.
        within_entire_page do
          find(
            ".ts-dropdown .option",
            text: /#{Regexp.escape(value)}/i, match: :prefer_exact
          ).click
        end
      end

      # Tom Select capybara helper for adding a tag to an
      # alchemy-tags-autocomplete field.
      def add_tom_select_tag(value, options)
        label = find_label_by_text(options[:from])

        within label.find(:xpath, "..") do
          find(".ts-control").click
          find(".ts-control input").send_keys(value, :return)
        end
      end

      # Tom Select capybara helper for remote (ajax) selects. Types the given
      # value into the search field to trigger the server request and selects the
      # matching option. Pass `select: false` to only search without selecting.
      def tom_select_search(value, options)
        scope =
          if options[:from]
            find_label_by_text(options[:from]).find(:xpath, "..")
          elsif options[:element_id] && options[:ingredient_role]
            find("#element_#{options[:element_id]} [data-ingredient-role='#{options[:ingredient_role]}']")
          else
            page
          end

        within scope do
          find(".ts-control").click
          find(".ts-control input").send_keys(value)
        end

        # The dropdown is appended to the body, so search the whole page for it.
        # `find` waits for the debounced remote request to deliver the option.
        unless options[:select] == false
          within_entire_page do
            find(
              ".ts-dropdown .option",
              text: /#{Regexp.escape(value)}/i, match: :prefer_exact
            ).click
          end
        end
      end

      # @deprecated Use {#tom_select_search} instead.
      def select2_search(value, options)
        Alchemy::Deprecation.warn(
          "Alchemy::TestSupport::CapybaraHelpers#select2_search is deprecated. Use #tom_select_search instead."
        )
        tom_select_search(value, options)
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
        find "label",
          text: /#{Regexp.escape(text)}/i,
          match: :one
      rescue Capybara::ElementNotFound
        find %([content="#{text}"]), match: :one
      end
    end
  end
end
