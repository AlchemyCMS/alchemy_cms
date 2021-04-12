# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_link_view" do
  let(:ingredient) { Alchemy::Ingredients::Link.new(value: "http://google.com") }

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Link.new(value: nil) }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end

  it "renders a link" do
    render ingredient
    expect(rendered).to eq('<a href="http://google.com">http://google.com</a>')
  end

  context "with text option" do
    let(:options) { { text: "Google" } }

    it "renders a link" do
      render ingredient, options: options
      expect(rendered).to eq('<a href="http://google.com">Google</a>')
    end
  end

  context "with text setting on ingredient definition" do
    before do
      allow(ingredient).to receive(:settings).and_return({ text: "Yahoo" })
    end

    it "renders a link" do
      render ingredient
      expect(rendered).to eq('<a href="http://google.com">Yahoo</a>')
    end
  end
end
