# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PublishElement do
  let(:element) do
    create(:alchemy_element, :with_ingredients, tag_list: "red, yellow")
  end

  let(:differences) { {} }

  subject { described_class.new(element).call(differences) }

  it "copies the element with its ingredients and tags" do
    expect(subject).to be_persisted
    expect(subject.ingredients.count).to eq(element.ingredients.count)
    expect(subject.ingredients.pluck(:id)).not_to eq(element.ingredients.pluck(:id))
    expect(subject.tag_list).to eq(element.tag_list)
  end

  context "with differences" do
    let(:new_page_version) { create(:alchemy_page_version, :published) }
    let(:differences) { {page_version_id: new_page_version.id} }

    it "applies the given differences to the copy" do
      expect(subject.page_version_id).to eq(new_page_version.id)
    end
  end

  context "with nested elements" do
    let(:element) { create(:alchemy_element) }

    let!(:current_nested) do
      create(:alchemy_element, parent_element: element, page_version: element.page_version, public_on: 1.day.ago)
    end

    let!(:future_nested) do
      create(:alchemy_element, parent_element: element, page_version: element.page_version, public_on: 1.day.from_now)
    end

    let!(:draft_nested) do
      create(:alchemy_element, parent_element: element, page_version: element.page_version, public_on: nil)
    end

    let!(:expired_nested) do
      create(:alchemy_element, parent_element: element, page_version: element.page_version, public_on: 2.days.ago, public_until: 1.day.ago)
    end

    it "only copies publishable nested elements" do
      expect(subject.all_nested_elements.count).to eq(2)
    end

    it "does not copy draft nested elements" do
      expect(subject.all_nested_elements.map(&:public_on)).to all(be_present)
    end

    it "does not copy expired nested elements" do
      expect(subject.all_nested_elements.map(&:public_until)).to all(be_nil)
    end
  end
end
