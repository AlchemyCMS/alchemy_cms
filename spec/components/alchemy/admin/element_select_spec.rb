# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementSelect, type: :component do
  before do
    allow_any_instance_of(Alchemy::ElementDefinition).to receive(:icon_file)
      .and_return(%(<svg class="icon"></svg>).html_safe)
    render
  end

  subject(:render) do
    render_inline described_class.new(element_definitions, field_name: "element[name]")
  end

  let(:element_definitions) do
    [
      Alchemy::ElementDefinition.new(
        "name" => "headline",
        "hint" => "Use this for headlines."
      )
    ]
  end

  it "renders a native select enhanced as alchemy-element-select" do
    expect(page).to have_selector(
      %(select[is="alchemy-element-select"][placeholder="Select element"][required][name="element[name]"]),
      visible: :all
    )
  end

  it "renders an option per element with its display name" do
    expect(page).to have_selector(
      %(select[is="alchemy-element-select"] option[value="headline"]),
      text: "Headline",
      visible: :all
    )
  end

  it "renders the element icon and hint as option data attributes" do
    option = page.find(%(select option[value="headline"]), visible: :all)
    expect(option["data-icon"]).to eq(%(<svg class="icon"></svg>))
    expect(option["data-hint"]).to eq("Use this for headlines.")
  end

  context "with autofocus: true" do
    subject(:render) do
      render_inline described_class.new(element_definitions, field_name: "element[name]", autofocus: true)
    end

    it "renders the select with autofocus attribute" do
      expect(page).to have_selector("select[autofocus]", visible: :all)
    end
  end

  context "with one element definition" do
    it "preselects the only option" do
      expect(page).to have_selector(%(option[value="headline"][selected]), visible: :all)
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

    it "preselects no option" do
      expect(page).to have_selector("select[is='alchemy-element-select'] option", count: 2, visible: :all)
      expect(page).to_not have_selector("option[selected]", visible: :all)
    end
  end
end
