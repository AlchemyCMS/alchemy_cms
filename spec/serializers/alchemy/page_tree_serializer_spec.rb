# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PageTreeSerializer do
  let(:ability) { Alchemy::Permissions.new(nil) } # guest

  # The serializer is normally fed a PageTreePage delegator from
  # PageTreePreloader. These specs pass a plain Alchemy::Page to exercise the
  # safeguard in #page_elements that supports an un-preloaded page.
  describe "#page_elements with a plain Alchemy::Page" do
    subject(:json) do
      JSON.parse(
        described_class.new(page, ability: ability, elements: "true").to_json
      )
    end

    let!(:element) do
      create(:alchemy_element, name: "article", page: page, page_version: page.public_version)
    end

    context "when the ability can read the page" do
      let(:page) { create(:alchemy_page, :public) }

      it "includes the page elements" do
        expect(json["pages"].first["elements"]).to_not be_empty
      end
    end

    context "when the ability cannot read the page" do
      let(:page) { create(:alchemy_page, :public, :restricted) }

      it "omits the page elements" do
        expect(json["pages"].first["elements"]).to eq([])
      end
    end
  end
end
