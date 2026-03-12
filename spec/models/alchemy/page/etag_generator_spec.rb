require "rails_helper"

RSpec.describe Alchemy::Page::EtagGenerator do
  let(:generator) { described_class.new(page) }
  let(:page) { create(:alchemy_page, :public) }

  describe "#call" do
    subject { generator.call }

    it "includes the page" do
      expect(subject).to include(page)
    end

    it "includes published elements ids" do
      expected = page.public_version.elements.published.order(:id).pluck(:id)
      expect(subject[1]).to eq(expected)
    end

    context "with additional arguments" do
      let(:user) { build(:alchemy_dummy_user) }

      subject { generator.call(user) }

      it "includes the argument" do
        expect(subject).to include(user)
      end
    end

    context "when element becomes published" do
      let!(:scheduled_element) do
        create(:alchemy_element, page_version: page.public_version, public_on: 1.hour.from_now)
      end

      it "changes the etag when element becomes visible", :aggregate_failures do
        etag_before = subject[1]
        travel 2.hours do
          etag_after = generator.call[1]
          expect(etag_after).not_to eq(etag_before)
        end
      end
    end

    context "when one element replaces another" do
      let!(:default_header) do
        create(:alchemy_element, page_version: page.public_version, public_on: 1.day.ago, public_until: 1.hour.from_now)
      end

      let!(:seasonal_header) do
        create(:alchemy_element, page_version: page.public_version, public_on: 1.hour.from_now)
      end

      it "changes the etag even when published element count stays the same", :aggregate_failures do
        etag_before = subject[1]
        expect(etag_before.length).to eq(1)

        travel 2.hours do
          etag_after = generator.call[1]
          expect(etag_after.length).to eq(1)
          expect(etag_after).not_to eq(etag_before)
        end
      end
    end
  end
end
