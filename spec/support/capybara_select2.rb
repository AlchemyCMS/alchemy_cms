# frozen_string_literal: true

module CapybaraSelect2
  # Select2 capybara helper
  def select2(value, options)
    label = find('label:not(.select2-offscreen)',
      text: /#{Regexp.escape(options[:from])}/i,
      match: :one)

    within label.first(:xpath, ".//..") do
      options[:from] = "##{find('.select2-container')['id']}"
    end

    find(options[:from]).find('a').click

    within(:xpath, '//body') do
      page.find("div.select2-result-label",
        text: /#{Regexp.escape(value)}/i, match: :prefer_exact).click
    end
  end
end
