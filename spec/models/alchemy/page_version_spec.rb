# frozen_string_literal: true

require "rails_helper"

describe Alchemy::PageVersion do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to have_many(:elements) }

  let(:page) { create(:alchemy_page) }

  describe ".drafts" do
    let!(:draft_versions) { page.versions.to_a }

    subject { described_class.drafts }

    before do
      Alchemy::PageVersion.create!(page: page, public_on: Time.current)
    end

    it "only includes pages without public_on date" do
      expect(subject.map(&:public_on).uniq).to eq [nil]
    end
  end

  describe ".published" do
    subject(:published) { described_class.published }

    let!(:public_one) { Alchemy::PageVersion.create!(page: page, public_on: Date.yesterday) }
    let!(:public_two) { Alchemy::PageVersion.create!(page: page, public_on: Time.current) }
    let!(:non_public) { page.draft_version }

    it "returns currently published page versions" do
      expect(published).to include(public_one)
      expect(published).to include(public_two)
      expect(published).to_not include(non_public)
    end

    it "latest currently published version is first in order" do
      expect(published.first).to eq(public_two)
    end
  end

  describe ".public_on" do
    let!(:public_one) { create(:alchemy_page_version, :published) }
    let!(:public_two) { create(:alchemy_page_version, public_on: Date.tomorrow) }
    let!(:non_public) { create(:alchemy_page_version) }

    context "without time given" do
      subject(:public_on) { described_class.public_on }

      it "returns page versions currently public" do
        aggregate_failures do
          expect(public_on).to include(public_one)
          expect(public_on).to_not include(public_two)
          expect(public_on).to_not include(non_public)
        end
      end
    end

    context "with time given" do
      subject(:public_on) { described_class.public_on(Date.tomorrow + 1.day) }

      it "returns page versions public on that time" do
        aggregate_failures do
          expect(public_on).to include(public_one)
          expect(public_on).to include(public_two)
          expect(public_on).to_not include(non_public)
        end
      end
    end
  end

  describe "#public?" do
    subject { page_version.public? }

    context "when public_on is not set" do
      let(:page_version) { build(:alchemy_page_version, public_on: nil) }

      it { is_expected.to be(false) }
    end

    context "when public_on is set to past date" do
      context "and public_until is set to nil" do
        let(:page_version) do
          build(:alchemy_page_version,
                public_on: Time.current - 2.days,
                public_until: nil)
        end

        it { is_expected.to be(true) }
      end

      context "and public_until is set to future date" do
        let(:page_version) do
          build(:alchemy_page_version,
                public_on: Time.current - 2.days,
                public_until: Time.current + 2.days)
        end

        it { is_expected.to be(true) }
      end

      context "and public_until is set to past date" do
        let(:page_version) do
          build(:alchemy_page_version,
                public_on: Time.current - 2.days,
                public_until: Time.current - 1.days)
        end

        it { is_expected.to be(false) }
      end
    end

    context "when public_on is set to future date" do
      let(:page_version) { build(:alchemy_page_version, public_on: Time.current + 2.days) }

      it { is_expected.to be(false) }
    end

    describe "dependent element destruction" do
      let!(:parent_element) { create(:alchemy_element, :with_nestable_elements, :with_contents) }
      let!(:nested_element) { parent_element.nested_elements.first }
      let!(:normal_element) { create(:alchemy_element, :with_contents) }

      let(:page_version) { create(:alchemy_page_version) }

      before do
        Alchemy::Element.update_all(page_version_id: page_version.id)
      end

      it "deletes all elements along with the page version" do
        page_version.destroy!
        expect(Alchemy::Element.count).to be_zero
        expect(Alchemy::Content.count).to be_zero
        expect(Alchemy::EssenceText.count).to be_zero
        expect(Alchemy::EssencePicture.count).to be_zero
        expect(Alchemy::EssenceRichtext.count).to be_zero
      end
    end

    describe "#element_repository" do
      let(:page_version) { create(:alchemy_page_version, :with_elements) }
      subject { page_version.element_repository }

      it "is an element repository containing the pages elements" do
        expect(Alchemy::ElementsRepository).to receive(:new).with(page_version.elements).and_call_original
        expect(subject).to be_a(Alchemy::ElementsRepository)
      end
    end
  end
end
