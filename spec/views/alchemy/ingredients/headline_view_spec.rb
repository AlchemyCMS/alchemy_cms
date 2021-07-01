# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_headline_view" do
  let(:ingredient) { Alchemy::Ingredients::Headline.new(value: "Hello", level: 2) }

  it "renders headline for level" do
    render ingredient
    expect(rendered).to have_selector("h2")
    expect(rendered).to have_content("Hello")
  end

  context "without size" do
    it "does not add size class" do
      render ingredient
      expect(rendered).to_not have_selector(".h1")
    end
  end

  context "with size" do
    let(:ingredient) { Alchemy::Ingredients::Headline.new(value: "Hello", level: 2, size: 1) }

    it "adds size class" do
      render ingredient
      expect(rendered).to have_selector("h2.h1")
    end
  end
end
