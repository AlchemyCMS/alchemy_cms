# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Drops::IngredientDrop do
  let(:ingredient) { build_stubbed(:alchemy_ingredient_text, role: "intro", value: "Tom & <Jerry>", link: "/foo") }

  subject(:drop) { described_class.new(ingredient) }

  it "exposes role and type" do
    expect(drop.role).to eq("intro")
    expect(drop.type).to eq("Text")
  end

  it "exposes the escaped value" do
    expect(drop.value).to eq("Tom &amp; &lt;Jerry&gt;")
    expect(drop.value).to be_html_safe
  end

  it "exposes the attributes stored in the data column" do
    expect(drop.invoke_drop("link")).to eq("/foo")
  end

  it "does not expose other methods of the record" do
    expect(drop.invoke_drop("destroy")).to be_nil
    expect(drop.invoke_drop("element")).to be_nil
  end

  describe "#present" do
    it { expect(drop.present).to be(true) }

    context "without a value" do
      let(:ingredient) { build_stubbed(:alchemy_ingredient_text, value: nil) }

      it { expect(drop.present).to be(false) }

      it "compares to blank in templates" do
        template = Liquid::Template.parse("{% if ingredient == blank %}empty{% endif %}")
        expect(template.render!("ingredient" => drop)).to eq("empty")
      end
    end
  end

  context "with a related page" do
    let(:page) { build_stubbed(:alchemy_page) }
    let(:ingredient) { build_stubbed(:alchemy_ingredient_page, page: page) }

    it "returns the page as drop" do
      expect(drop.value).to eq(Alchemy::Liquid::Drops::PageDrop.new(page))
    end
  end

  context "with a related picture" do
    let(:ingredient) { build_stubbed(:alchemy_ingredient_picture, picture: build_stubbed(:alchemy_picture)) }

    it "does not expose the picture" do
      expect(drop.value).to be_nil
    end
  end

  context "with a boolean" do
    let(:ingredient) { build_stubbed(:alchemy_ingredient_boolean, value: "1") }

    it "returns the typecasted value" do
      expect(drop.value).to be(true)
    end
  end
end
