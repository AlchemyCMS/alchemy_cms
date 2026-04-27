# frozen_string_literal: true

RSpec.shared_examples_for "being publishable" do |factory_name|
  describe "validations" do
    context "when public_until is older than public_on" do
      let(:record) do
        build(
          factory_name,
          public_on: Time.current,
          public_until: Time.current - 1.day
        )
      end

      it "is not valid" do
        expect(record).not_to be_valid
        expect(record.errors[:public_until]).to include(
          I18n.t("errors.attributes.public_until.must_be_after_public_on")
        )
      end
    end
  end

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

    it "delegates to the resolver" do
      expect(Alchemy.config.publishable_resolver).to receive(:draft)
      described_class.draft
    end
  end

  describe ".scheduled" do
    subject { described_class.scheduled }

    let!(:public_one) { create(factory_name, public_on: Date.yesterday) }
    let!(:public_two) { create(factory_name, public_on: Time.current) }
    let!(:non_public) { create(factory_name, public_on: nil) }

    it "returns currently scheduled records" do
      # Filter to test records only, as factories may create additional records as side effects
      scheduled = subject.where(id: [public_one.id, public_two.id, non_public.id])
      expect(scheduled).to match_array([
        public_one,
        public_two
      ])
    end

    it "delegates to the resolver" do
      expect(Alchemy.config.publishable_resolver).to receive(:scheduled)
      subject
    end
  end

  describe ".published" do
    let!(:public_one) { create(factory_name, public_on: Date.yesterday) }
    let!(:public_two) { create(factory_name, public_on: Date.tomorrow) }
    let!(:non_public) { create(factory_name, public_on: nil) }

    it "delegates to the resolver" do
      expect(Alchemy.config.publishable_resolver).to receive(:published)
      described_class.published
    end

    context "without time given" do
      subject { described_class.published }

      it "returns records currently public" do
        # Filter to test records only, as factories may create additional records as side effects
        published = subject.where(id: [public_one.id, public_two.id, non_public.id])
        expect(published).to match_array([
          public_one
        ])
      end
    end

    context "with time given" do
      subject { described_class.published(at: Date.tomorrow + 1.day) }

      it "returns records public on that time" do
        # Filter to test records only, as factories may create additional records as side effects
        published = subject.where(id: [public_one.id, public_two.id, non_public.id])
        expect(published).to match_array([
          public_one,
          public_two
        ])
      end
    end
  end

  describe "#scheduled?" do
    subject { record.scheduled? }

    let(:record) { build(factory_name, public_on:, public_until:) }
    let(:public_on) { nil }
    let(:public_until) { nil }

    it "delegates to the resolver" do
      expect_any_instance_of(Alchemy.config.publishable_resolver).to receive(:scheduled?)
      subject
    end

    context "when public_on is nil" do
      context "and public_until is nil" do
        it { expect(subject).to be(false) }
      end

      context "and public_until is in the past" do
        let(:public_until) { Date.yesterday }

        it "returns false" do
          expect(subject).to be(false)
        end
      end

      context "when public_until is in the future" do
        let(:public_until) { Date.tomorrow }

        it "returns true" do
          expect(subject).to be(true)
        end
      end
    end

    context "when public_on is in the past" do
      let(:public_on) { Date.yesterday }

      context "and public_until is nil" do
        let(:public_until) { nil }

        it { expect(subject).to be(false) }
      end

      context "and public_until is in the future" do
        let(:public_until) { Date.tomorrow }

        it "returns true" do
          expect(subject).to be(true)
        end
      end
    end

    context "when public_on is in the future" do
      let(:public_on) { Date.tomorrow }
      let(:public_until) { nil }

      it "returns true" do
        expect(subject).to be(true)
      end
    end
  end

  describe "#public?" do
    subject { page_version.public? }

    let(:page_version) { build(factory_name) }

    it "delegates to the resolver" do
      expect_any_instance_of(Alchemy.config.publishable_resolver).to receive(:public?)
      subject
    end

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

    context "when Current.preview_time is set" do
      let(:page_version) do
        build(factory_name,
          public_on: Time.zone.parse("2025-06-01 00:00:00"),
          public_until: Time.zone.parse("2025-06-30 23:59:59"))
      end

      it "uses preview_time to determine visibility" do
        Alchemy::Current.preview_time = Time.zone.parse("2025-06-15 12:00:00")
        expect(page_version.public?).to be(true)
      end

      it "returns false when preview_time is outside the public range" do
        Alchemy::Current.preview_time = Time.zone.parse("2025-07-15 12:00:00")
        expect(page_version.public?).to be(false)
      end

      it "returns false when preview_time is before public_on" do
        Alchemy::Current.preview_time = Time.zone.parse("2025-05-15 12:00:00")
        expect(page_version.public?).to be(false)
      end
    end
  end
end
