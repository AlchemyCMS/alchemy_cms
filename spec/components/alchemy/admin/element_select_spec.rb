# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementSelect, type: :component do
  before do
    allow(Alchemy::Element).to receive(:icon_file)
    render
  end

  subject(:render) do
    render_inline described_class.new(element_definitions, field_name: "element[name]")
  end

  let(:element_definitions) do
    [
      Alchemy::ElementDefinition.new(
        "name" => "headline"
      )
    ]
  end

  it "renders input field without value attribute" do
    expect(page).to have_selector("input[value='headline']")
  end

  it "renders input field with options for element-select" do
    expect(page).to have_selector(
      "input[is='alchemy-element-select'][data-placeholder='Select element'][autofocus][required][name='element[name]']"
    )
  end

  it "renders data-options for select2" do
    input = page.find("input")
    options = JSON.parse(input["data-options"])
    expect(options).to match_array([
      {
        "text" => "Headline",
        "icon" => an_instance_of(String),
        "id" => "headline"
      }
    ])
  end

  context "with one element definition" do
    it "renders input field without value attribute" do
      expect(page).to have_selector("input[value='headline']")
    end
  end

  context "with many element definitions" do
    let(:element_definitions) do
      [
        Alchemy::ElementDefinition.new(
          "name" => "headline"
        ),
        Alchemy::ElementDefinition.new(
          "name" => "text"
        )
      ]
    end

    it "renders input field without value attribute" do
      expect(page).to have_selector("input[is='alchemy-element-select']")
      expect(page).to_not have_selector("input[value]")
    end
  end
end
