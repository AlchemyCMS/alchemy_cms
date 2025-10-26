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

  it "renders alchemy-element-select with input field" do
    expect(page).to have_selector(
      "alchemy-element-select[placeholder='Select element'] input[autofocus][required][name='element[name]']"
    )
  end

  it "renders options for select2" do
    component = page.find("alchemy-element-select")
    options = JSON.parse(component["options"])
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
      expect(page).to have_selector("alchemy-element-select input")
      expect(page).to_not have_selector("input[value]")
    end
  end
end
