# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_boolean_view" do
  context "with true as value" do
    let(:ingredient) { Alchemy::Ingredients::Boolean.new(value: true) }

    it "renders true" do
      render ingredient
      expect(rendered).to have_content("True")
    end
  end

  context "with false as value" do
    let(:ingredient) { Alchemy::Ingredients::Boolean.new(value: false) }

    it "renders false" do
      render ingredient
      expect(rendered).to have_content("False")
    end
  end
end
