# frozen_string_literal: true

module CapybaraSelect2
  # Select2 capybara helper
  def select2(value, options)
    label = find_label_by_text(options[:from])

    within label.first(:xpath, ".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end

    find(options[:from]).find("a").click

    within_entire_page do
      page.find("div.select2-result-label",
        text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
    end
  end

  def select2_search(value, options)
    label = find_label_by_text(options[:from])

    within label.first(:xpath, ".//..") do
      options[:from] = "##{find(".select2-container")["id"]}"
    end

    find("#{options[:from]}:not(.select2-container-disabled):not(.select2-offscreen)").click

    within_entire_page do
      find("input.select2-input.select2-focused").set(value)
      expect(page).to have_selector(".select2-result-label", visible: true)
      find("div.select2-result-label", text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
      expect(page).not_to have_selector(".select2-result-label")
    end
  end

  def click_button_with_label(label)
    label = find("label", text: label)
    within label.first(:xpath, ".//..") do
      first("button").click
    end
  end

  private

  def within_entire_page(&block)
    within(:xpath, "//body", &block)
  end

  def find_label_by_text(text)
    find "label:not(.select2-offscreen)",
      text: /#{Regexp.escape(text)}/i,
      match: :one
  end
end
