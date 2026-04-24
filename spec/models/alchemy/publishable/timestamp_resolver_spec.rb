# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Publishable::TimestampResolver do
  describe ".scheduled" do
    let!(:draft) { create(:alchemy_page_version, public_on: nil) }
    let!(:published) { create(:alchemy_page_version, public_on: Time.current) }

    it "returns records with public_on date set" do
      result = described_class.scheduled(Alchemy::PageVersion.where(id: [draft.id, published.id]))
      expect(result).to eq([published])
    end
  end

  describe ".published" do
    let!(:past) { create(:alchemy_page_version, public_on: Date.yesterday) }
    let!(:future) { create(:alchemy_page_version, public_on: Date.tomorrow) }
    let!(:draft) { create(:alchemy_page_version, public_on: nil) }

    it "returns records currently public" do
      result = described_class.published(
        Alchemy::PageVersion.where(id: [past.id, future.id, draft.id]),
        at: Time.current
      )
      expect(result).to eq([past])
    end

    it "returns records public at given time" do
      result = described_class.published(
        Alchemy::PageVersion.where(id: [past.id, future.id, draft.id]),
        at: Date.tomorrow + 1.day
      )
      expect(result).to match_array([past, future])
    end
  end

  describe ".draft" do
    let!(:draft) { create(:alchemy_page_version, public_on: nil) }
    let!(:published) { create(:alchemy_page_version, public_on: Time.current) }

    it "returns records without public_on date" do
      result = described_class.draft(Alchemy::PageVersion.where(id: [draft.id, published.id]))
      expect(result).to eq([draft])
    end
  end

  let(:record) { build(:alchemy_page_version, public_on: public_on, public_until: public_until) }
  let(:public_on) { nil }
  let(:public_until) { nil }

  subject(:resolver) { described_class.new(record) }

  describe "#public?" do
    context "when public_on is nil" do
      it { expect(resolver.public?).to be(false) }
    end

    context "when public_on is in the past and public_until is nil" do
      let(:public_on) { Time.current - 2.days }

      it { expect(resolver.public?).to be(true) }
    end

    context "when public_on is in the past and public_until is in the future" do
      let(:public_on) { Time.current - 2.days }
      let(:public_until) { Time.current + 2.days }

      it { expect(resolver.public?).to be(true) }
    end

    context "when public_on is in the past and public_until is in the past" do
      let(:public_on) { Time.current - 2.days }
      let(:public_until) { Time.current - 1.day }

      it { expect(resolver.public?).to be(false) }
    end

    context "when public_on is in the future" do
      let(:public_on) { Time.current + 2.days }

      it { expect(resolver.public?).to be(false) }
    end

    context "when at: is given" do
      let(:public_on) { Time.zone.parse("2025-06-01 00:00:00") }
      let(:public_until) { Time.zone.parse("2025-06-30 23:59:59") }

      it "uses the given time" do
        expect(resolver.public?(at: Time.zone.parse("2025-06-15 12:00:00"))).to be(true)
        expect(resolver.public?(at: Time.zone.parse("2025-07-15 12:00:00"))).to be(false)
        expect(resolver.public?(at: Time.zone.parse("2025-05-15 12:00:00"))).to be(false)
      end
    end

    context "when Current.preview_time is set" do
      let(:public_on) { Time.zone.parse("2025-06-01 00:00:00") }
      let(:public_until) { Time.zone.parse("2025-06-30 23:59:59") }

      it "uses preview_time by default" do
        Alchemy::Current.preview_time = Time.zone.parse("2025-06-15 12:00:00")
        expect(resolver.public?).to be(true)
      end
    end
  end

  describe "#scheduled?" do
    context "when public_on is nil and public_until is nil" do
      it { expect(resolver.scheduled?).to be(false) }
    end

    context "when public_on is nil and public_until is in the future" do
      let(:public_until) { Date.tomorrow }

      it { expect(resolver.scheduled?).to be(true) }
    end

    context "when public_on is in the past and public_until is nil" do
      let(:public_on) { Date.yesterday }

      it { expect(resolver.scheduled?).to be(false) }
    end

    context "when public_on is in the past and public_until is in the future" do
      let(:public_on) { Date.yesterday }
      let(:public_until) { Date.tomorrow }

      it { expect(resolver.scheduled?).to be(true) }
    end

    context "when public_on is in the future" do
      let(:public_on) { Date.tomorrow }

      it { expect(resolver.scheduled?).to be(true) }
    end
  end

  describe "#publishable?" do
    context "when public_on is nil" do
      it { expect(resolver.publishable?).to be(false) }
    end

    context "when public_on is set and public_until is nil" do
      let(:public_on) { Time.current }

      it { expect(resolver.publishable?).to be(true) }
    end

    context "when public_on is set and public_until is in the future" do
      let(:public_on) { Time.current }
      let(:public_until) { Time.current + 1.day }

      it { expect(resolver.publishable?).to be(true) }
    end

    context "when public_on is set and public_until is in the past" do
      let(:public_on) { Time.current - 2.days }
      let(:public_until) { Time.current - 1.day }

      it { expect(resolver.publishable?).to be(false) }
    end
  end
end
