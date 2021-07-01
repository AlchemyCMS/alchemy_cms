# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_select_view" do
  let(:ingredient) { Alchemy::Ingredients::Select.new(value: "blue") }

  it "renders the ingredient" do
    render ingredient
    expect(rendered).to have_content("blue")
  end
end
