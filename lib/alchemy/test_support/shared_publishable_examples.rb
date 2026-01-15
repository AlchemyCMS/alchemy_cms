# frozen_string_literal: true

RSpec.shared_examples_for "being publishable" do |factory_name|
  describe ".draft" do
    let!(:draft_versions) { create_list(factory_name, 2, public_on: nil) }

    subject { described_class.draft.map(&:public_on) }

    before do
      create(factory_name, public_on: Time.current)
      subject.uniq!
    end

    it "only includes records without public_on date" do
      expect(subject).to eq [nil]
    end
  end

  describe ".scheduled" do
    subject(:scheduled) { described_class.scheduled }

    let!(:public_one) { create(factory_name, public_on: Date.yesterday) }
    let!(:public_two) { create(factory_name, public_on: Time.current) }
    let!(:non_public) { create(factory_name) }

    it "returns currently scheduled records" do
      expect(scheduled).to include(public_one)
      expect(scheduled).to include(public_two)
      expect(scheduled).to_not include(non_public)
    end
  end

  describe ".published" do
    let!(:public_one) { create(factory_name, :published) }
    let!(:public_two) { create(factory_name, public_on: Date.tomorrow) }
    let!(:non_public) { create(factory_name) }

    context "without time given" do
      subject(:published) { described_class.published }

      it "returns records currently public" do
        aggregate_failures do
          expect(published).to include(public_one)
          expect(published).to_not include(public_two)
          expect(published).to_not include(non_public)
        end
      end
    end

    context "with time given" do
      subject(:published) { described_class.published(at: Date.tomorrow + 1.day) }

      it "returns records public on that time" do
        aggregate_failures do
          expect(published).to include(public_one)
          expect(published).to include(public_two)
          expect(published).to_not include(non_public)
        end
      end
    end
  end

  describe "#public?" do
    subject { page_version.public? }

    context "when public_on is not set" do
      let(:page_version) { build(factory_name, public_on: nil) }

      it { is_expected.to be(false) }
    end

    context "when public_on is set to past date" do
      context "and public_until is set to nil" do
        let(:page_version) do
          build(factory_name,
            public_on: Time.current - 2.days,
            public_until: nil)
        end

        it { is_expected.to be(true) }
      end

      context "and public_until is set to future date" do
        let(:page_version) do
          build(factory_name,
            public_on: Time.current - 2.days,
            public_until: Time.current + 2.days)
        end

        it { is_expected.to be(true) }
      end

      context "and public_until is set to past date" do
        let(:page_version) do
          build(factory_name,
            public_on: Time.current - 2.days,
            public_until: Time.current - 1.days)
        end

        it { is_expected.to be(false) }
      end
    end

    context "when public_on is set to future date" do
      let(:page_version) { build(factory_name, public_on: Time.current + 2.days) }

      it { is_expected.to be(false) }
    end
  end
end
