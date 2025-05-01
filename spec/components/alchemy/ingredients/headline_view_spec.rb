# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::HeadlineView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Headline.new(value: "Hello", level: 2, dom_id: "se-headline") }

  it "renders headline for level" do
    render_inline described_class.new(ingredient)
    expect(page).to have_selector("h2")
    expect(page).to have_content("Hello")
  end

  context "with level option passed" do
    it "renders headline for given level" do
      render_inline described_class.new(ingredient, level: 1)
      expect(page).to have_selector("h1")
      expect(page).to have_content("Hello")
    end
  end

  context "with dom_id" do
    it "adds id" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("h2#se-headline")
    end
  end

  context "without size" do
    it "does not add size class" do
      render_inline described_class.new(ingredient)
      expect(page).to_not have_selector(".h1")
    end
  end

  context "with size" do
    let(:ingredient) { Alchemy::Ingredients::Headline.new(value: "Hello", level: 2, size: 1) }

    it "adds size class" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("h2.h1")
    end
  end

  context "with html_options[:class]" do
    it "adds class" do
      render_inline described_class.new(ingredient, html_options: {class: "bold"})
      expect(page).to have_selector("h2.bold")
    end
  end
end
