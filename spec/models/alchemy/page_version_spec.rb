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

    context "with another time passed" do
      subject(:published) { described_class.published(on: tomorrow) }

      let(:tomorrow) { Date.tomorrow.to_time }

      before do
        public_one.update_columns(public_until: Time.current)
      end

      let!(:public_three) { Alchemy::PageVersion.create!(page: page, public_on: tomorrow) }

      it "returns page versions published on that time" do
        expect(published).to_not include(public_one)
        expect(published).to include(public_two)
        expect(published).to include(public_three)
      end
    end
  end
end
