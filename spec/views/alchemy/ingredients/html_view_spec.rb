# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_html_view" do
  let(:ingredient) { Alchemy::Ingredients::Html.new(value: '<script>alert("hacked");</script>') }

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Html.new(value: nil) }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end

  context "with value" do
    it "renders the raw html source" do
      render ingredient
      expect(rendered).to have_selector("script")
    end
  end
end
