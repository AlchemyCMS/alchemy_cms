# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader/tasks/ingredients_migrator"

RSpec.describe Alchemy::Upgrader::Tasks::IngredientsMigrator do
  let!(:element) do
    FactoryBot.create(
      :alchemy_element,
      name: "element_with_ingredients",
      autogenerate_ingredients: false,
      contents: [content1, content2]
    )
  end

  let(:content1) { Alchemy::Content.new(name: "headline", essence: headline) }
  let(:headline) { FactoryBot.create(:alchemy_essence_text) }
  let(:content2) { Alchemy::Content.new(name: "text", essence: text) }
  let(:text) { Alchemy::EssenceRichtext.new(body: "Hello World") }

  subject { described_class.new.create_ingredients }

  it "changes existing elements with contents and essences to ingredients" do
    expect(Alchemy::Content.count).to eq(2)
    expect(Alchemy::Ingredient.count).to eq(0)

    subject

    expect(Alchemy::Content.count).to eq(0)
    expect(Alchemy::Ingredient.count).to eq(2)
  end
end
