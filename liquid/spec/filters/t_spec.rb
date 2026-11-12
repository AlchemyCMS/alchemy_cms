# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Liquid::Filters#t", type: :helper do
  before do
    I18n.backend.store_translations(:en, liquid_spec: {
      hello: "Hello",
      greeting: "Hello %{name}",
      translated: {greeting: "Hi from the partial"}
    })
  end

  it "translates a key" do
    expect(render_liquid('{{ "liquid_spec.hello" | t }}')).to eq("Hello")
  end

  it "passes keyword arguments as interpolations" do
    expect(render_liquid('{{ "liquid_spec.greeting" | t: name: user }}', user: "Ada")).to eq("Hello Ada")
  end

  it "looks up keys starting with a dot relative to the template" do
    expect(helper.render(partial: "liquid_spec/translated").strip).to eq("Hi from the partial")
  end
end
