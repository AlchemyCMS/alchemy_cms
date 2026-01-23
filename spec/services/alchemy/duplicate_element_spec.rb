# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::DuplicateElement do
  let(:element) do
    create(:alchemy_element, :with_ingredients, tag_list: "red, yellow")
  end
  let(:differences) { {} }
  subject { described_class.new(element).call(differences) }

  it "should not create ingredients from scratch" do
    expect(subject.ingredients.count).to eq(element.ingredients.count)
  end

  context "with differences" do
    let(:new_page_version) { create(:alchemy_page_version) }
    let(:differences) { {page_version_id: new_page_version.id} }

    it "should create a new record with all attributes of source except given differences" do
      expect(subject.page_version_id).to eq(new_page_version.id)
    end
  end

  it "should make copies of all ingredients of source" do
    expect(subject.ingredients).not_to be_empty
    expect(subject.ingredients.pluck(:id)).not_to eq(element.ingredients.pluck(:id))
  end

  it "the copy should include source element tags" do
    expect(subject.tag_list).to eq(element.tag_list)
  end

  context "with nested elements" do
    let(:element) do
      create(:alchemy_element, :with_ingredients, :with_nestable_elements, {
        tag_list: "red, yellow",
        page: create(:alchemy_page)
      })
    end

    before do
      element.nested_elements << create(:alchemy_element, name: "slide")
    end

    it "should copy nested elements" do
      expect(subject.nested_elements).to_not be_empty
    end

    context "copy to new page version" do
      let(:new_page_version) { create(:alchemy_page_version) }
      let(:differences) { {page_version_id: new_page_version.id} }

      it "should set page_version id to new page_version's id" do
        subject.nested_elements.each do |nested_element|
          expect(nested_element.page_version_id).to eq(new_page_version.id)
        end
      end
    end

    context "copy to new page version" do
      let(:public_version) do
        element.page.versions.create!(public_on: Time.current)
      end
      let(:differences) { {page_version_id: public_version.id} }

      it "sets page_version id" do
        subject.nested_elements.each do |nested_element|
          expect(nested_element.page_version_id).to eq(public_version.id)
        end
      end
    end

    context "with publishable_only option" do
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

      subject do
        described_class.new(element, publishable_only: true).call(differences)
      end

      it "only copies publishable nested elements" do
        expect(subject.all_nested_elements.count).to eq(2)
      end

      it "does not copy draft nested elements" do
        public_ons = subject.all_nested_elements.map(&:public_on)
        expect(public_ons).to all(be_present)
      end

      it "does not copy expired nested elements" do
        public_untils = subject.all_nested_elements.map(&:public_until)
        expect(public_untils).to all(be_nil)
      end
    end
  end
end
