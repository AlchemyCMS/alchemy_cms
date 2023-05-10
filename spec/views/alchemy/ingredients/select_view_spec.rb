# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_select_view" do
  let(:ingredient) { Alchemy::Ingredients::Select.new(value: "blue") }

  it "renders the ingredients value" do
    render ingredient
    expect(rendered).to have_content("blue")
  end

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Select.new(value: "") }

    it "does not render" do
      render ingredient
      expect(rendered).to have_content("")
    end
  end
end
