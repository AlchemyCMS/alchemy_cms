# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::LinkView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Link.new(value: "http://google.com") }

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Link.new(value: nil) }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  it "renders a link" do
    render_inline described_class.new(ingredient)
    expect(page).to have_selector('a[href="http://google.com"]', text: "http://google.com")
  end

  context "with text option" do
    let(:options) { {text: "Google"} }

    it "renders a link" do
      render_inline described_class.new(ingredient, **options)
      expect(page).to have_selector('a[href="http://google.com"]', text: "Google")
    end
  end

  context "with text setting on ingredient definition" do
    before do
      allow(ingredient).to receive(:settings).and_return({text: "Yahoo"})
    end

    it "renders a link" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector('a[href="http://google.com"]', text: "Yahoo")
    end
  end

  context "with html options" do
    it "renders them" do
      render_inline described_class.new(ingredient, html_options: {class: "foo"})
      expect(page).to have_selector('a.foo[href="http://google.com"]', text: "http://google.com")
    end
  end

  context "with link target set to '_blank'" do
    let(:ingredient) do
      Alchemy::Ingredients::Link.new(value: "http://google.com", link_target: "_blank")
    end

    it "adds rel noopener noreferrer" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector(
        'a[target="_blank"][rel="noopener noreferrer"][href="http://google.com"]', text: "http://google.com"
      )
    end
  end

  context "with link target set to 'blank'" do
    let(:ingredient) do
      Alchemy::Ingredients::Link.new(value: "http://google.com", link_target: "blank")
    end

    it "sets target '_blank' and adds rel noopener noreferrer" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector(
        'a[target="_blank"][rel="noopener noreferrer"][href="http://google.com"]', text: "http://google.com"
      )
    end
  end
end
