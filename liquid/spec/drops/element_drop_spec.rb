# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Drops::ElementDrop do
  let(:page) { create(:alchemy_page, autogenerate_elements: false) }
  let(:element) { create(:alchemy_element, :with_ingredients, name: "headline", page_version: page.draft_version) }

  subject(:drop) { described_class.new(element) }

  it "exposes the element's id and name" do
    expect(drop.id).to eq(element.id)
    expect(drop.name).to eq("headline")
  end

  it "exposes the escaped tag list" do
    allow(element).to receive(:tag_list).and_return(["<b>", "news"])
    expect(drop.tag_list).to eq(["&lt;b&gt;", "news"])
  end

  it "exposes the ingredients keyed by role" do
    ingredients = drop.ingredients
    expect(ingredients).to be_a(Alchemy::Liquid::Drops::IngredientsDrop)
    expect(ingredients.invoke_drop("headline").record).to eq(element.ingredient_by_role(:headline))
    expect(ingredients.invoke_drop("unknown")).to be_nil
  end

  it "iterates over the ingredients" do
    expect(drop.ingredients.map(&:role)).to eq(element.ingredients.map(&:role))
  end

  it "exposes the visible nested elements as drops" do
    parent = create(:alchemy_element, name: "slider", page_version: page.draft_version, autogenerate_nested_elements: false)
    visible = create(:alchemy_element, name: "slide", parent_element: parent, page_version: page.draft_version)
    create(:alchemy_element, name: "slide", parent_element: parent, page_version: page.draft_version, public: false)

    expect(described_class.new(parent).nested_elements.map(&:record)).to eq([visible])
  end

  it "exposes the page as drop" do
    expect(drop.page).to eq(Alchemy::Liquid::Drops::PageDrop.new(page))
  end

  it "does not expose the record to templates" do
    expect(described_class.invokable?("record")).to be(false)
    expect(described_class.invokable?("name")).to be(true)
  end

  it "is readable from a template" do
    template = Liquid::Template.parse("{{ element.name }}:{{ element.ingredients.headline.role }}")
    expect(template.render!("element" => drop)).to eq("headline:headline")
  end
end
