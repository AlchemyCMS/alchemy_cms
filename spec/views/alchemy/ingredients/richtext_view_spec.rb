# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_richtext_view" do
  let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "richtext", value: "<h1>Lorem ipsum dolor sit amet</h1> <p>consectetur adipiscing elit.</p>", data: { stripped_body: "Lorem ipsum dolor sit amet consectetur adipiscing elit." }, element: element) }
  let(:options) { {} }

  subject do
    render ingredient, options: options
    rendered
  end

  it "renders the html body" do
    is_expected.to have_content("Lorem ipsum dolor sit amet consectetur adipiscing elit.")
    is_expected.to have_selector("h1")
  end

  context "with options[:plain_text] true" do
    let(:options) { { plain_text: true } }

    it "renders the plain text body" do
      is_expected.to have_content("Lorem ipsum dolor sit amet consectetur adipiscing elit.")
      is_expected.to_not have_selector("h1")
    end
  end

  context "with ingredient.settings[:plain_text] true" do
    before do
      allow(ingredient).to receive(:settings).and_return({ plain_text: true })
    end

    it "renders the text body" do
      is_expected.to have_content("Lorem ipsum dolor sit amet consectetur adipiscing elit.")
      is_expected.to_not have_selector("h1")
    end
  end
end
