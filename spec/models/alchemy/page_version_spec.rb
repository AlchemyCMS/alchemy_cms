# frozen_string_literal: true

require "rails_helper"

describe Alchemy::PageVersion do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to have_many(:elements) }

  describe ".drafts" do
    let(:page) { create(:alchemy_page) }
    let!(:draft_versions) { page.versions.to_a }

    subject { described_class.drafts }

    before do
      Alchemy::PageVersion.create!(page: page, public_on: Time.current)
    end

    it "only includes pages without public_on date" do
      expect(subject.map(&:public_on).uniq).to eq [nil]
    end
  end
end
