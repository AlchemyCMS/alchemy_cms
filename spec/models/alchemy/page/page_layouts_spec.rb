# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Page::PageLayouts do
  describe ".selectable_layouts" do
    let(:site) { create(:alchemy_site) }
    let!(:language) { create(:alchemy_language, code: :de) }
    subject { Alchemy::Page.selectable_layouts(language.id) }

    it "should not display hidden page layouts" do
      subject.each { |l| expect(l["hide"]).not_to eq(true) }
    end

    it "should not display layoutpages" do
      subject.each { |l| expect(l["layoutpage"]).not_to eq(true) }
    end

    context "with already taken layouts" do
      before do
        allow(Alchemy::PageLayout).to receive(:all).and_return([{ "unique" => true }])
        allow(Alchemy::Page).to receive(:where).and_return double(pluck: [1])
      end

      it "should not include unique layouts" do
        subject.each { |l| expect(l["unique"]).not_to eq(true) }
      end
    end

    context "with sites layouts present" do
      let(:definition) do
        { "name" => "default_site", "page_layouts" => %w(index) }
      end

      before do
        allow_any_instance_of(Alchemy::Site).to receive(:definition).and_return(definition)
      end

      it "should only return layouts for site" do
        expect(subject.length).to eq(1)
        expect(subject.first["name"]).to eq("index")
      end
    end

    context "with layoutpages set to true" do
      subject { Alchemy::Page.selectable_layouts(language.id, layoutpages: true) }

      it "should only return layoutpages" do
        subject.each { |l| expect(l["layoutpage"]).to eq(true) }
      end
    end
  end

  describe ".human_layout_name" do
    let(:layout) { { "name" => "contact" } }

    subject { Alchemy::Page.human_layout_name(layout["name"]) }

    context "with no translation present" do
      it "returns the name capitalized" do
        is_expected.to eq("Contact")
      end
    end

    context "with translation present" do
      before { expect(Alchemy).to receive(:t).and_return("Kontakt") }

      it "returns the translated name" do
        is_expected.to eq("Kontakt")
      end
    end
  end
end
