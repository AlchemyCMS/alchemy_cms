# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid do
  describe ".to_drop" do
    it "wraps Alchemy records into drops" do
      expect(described_class.to_drop(build_stubbed(:alchemy_element))).to be_a(Alchemy::Liquid::Drops::ElementDrop)
      expect(described_class.to_drop(build_stubbed(:alchemy_ingredient_text))).to be_a(Alchemy::Liquid::Drops::IngredientDrop)
      expect(described_class.to_drop(build_stubbed(:alchemy_page))).to be_a(Alchemy::Liquid::Drops::PageDrop)
      expect(described_class.to_drop(build_stubbed(:alchemy_node))).to be_a(Alchemy::Liquid::Drops::NodeDrop)
    end

    it "wraps hashes and arrays recursively and stringifies keys" do
      page = build_stubbed(:alchemy_page)
      expect(described_class.to_drop({options: {pages: [page]}})).to eq(
        "options" => {"pages" => [Alchemy::Liquid::Drops::PageDrop.new(page)]}
      )
    end

    it "passes Liquid compatible values" do
      time = Time.current
      expect(described_class.to_drop(["a", 1, 1.5, true, nil, time])).to eq(["a", 1, 1.5, true, nil, time])
    end

    it "removes other objects" do
      expect(described_class.to_drop([build_stubbed(:alchemy_picture), Object.new])).to eq([nil, nil])
    end
  end

  describe ".unwrap" do
    it "returns the record of a drop" do
      page = build_stubbed(:alchemy_page)
      expect(described_class.unwrap(Alchemy::Liquid::Drops::PageDrop.new(page))).to eq(page)
    end

    it "returns other objects as they are" do
      expect(described_class.unwrap("a")).to eq("a")
    end
  end

  describe ".configure_environment" do
    let(:shout) do
      Module.new do
        def shout(input) = input.to_s.upcase
      end
    end

    after do
      described_class.send(:environment_extensions).clear
      described_class.reset_environment!
    end

    it "registers custom filters and tags in the environment" do
      described_class.configure_environment { _1.register_filter(shout) }
      template = Liquid::Template.parse("{{ 'hi' | shout }}", environment: described_class.environment)
      expect(template.render!).to eq("HI")
    end

    it "keeps the Alchemy tags" do
      described_class.configure_environment { _1.register_filter(shout) }
      expect(described_class.environment.tags["ingredient"]).to eq(Alchemy::Liquid::Tags::Ingredient)
    end

    it "does not leak into the default Liquid environment" do
      expect(Liquid::Environment.default.tags["ingredient"]).to be_nil
    end
  end
end
