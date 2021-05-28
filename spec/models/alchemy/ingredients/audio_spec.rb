# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Audio do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  let(:audio_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "podcast",
      related_object: attachment,
    )
  end

  describe "#autoplay" do
    subject { audio_ingredient.autoplay }
    before { audio_ingredient.autoplay = false }
    it { is_expected.to eq(false) }
  end

  describe "#controls" do
    subject { audio_ingredient.controls }
    before { audio_ingredient.controls = true }
    it { is_expected.to eq(true) }
  end

  describe "#loop" do
    subject { audio_ingredient.loop }
    before { audio_ingredient.loop = false }
    it { is_expected.to eq(false) }
  end

  describe "#muted" do
    subject { audio_ingredient.muted }
    before { audio_ingredient.muted = true }
    it { is_expected.to eq(true) }
  end

  describe "#attachment" do
    subject { audio_ingredient.attachment }

    it { is_expected.to be_an(Alchemy::Attachment) }
  end

  describe "#attachment=" do
    let(:attachment) { Alchemy::Attachment.new }

    subject { audio_ingredient.attachment = attachment }

    it { is_expected.to be(attachment) }
  end

  describe "#attachment_id" do
    subject { audio_ingredient.attachment_id }

    it { is_expected.to be_an(Integer) }
  end

  describe "#attachment_id=" do
    let(:attachment) { Alchemy::Attachment.new(id: 111) }

    subject { audio_ingredient.attachment_id = attachment.id }

    it { is_expected.to be(111) }
    it { expect(audio_ingredient.related_object_type).to eq("Alchemy::Attachment") }
  end

  describe "#preview_text" do
    subject { audio_ingredient.preview_text }

    context "with a attachment" do
      let(:attachment) do
        Alchemy::Attachment.new(name: "A very long file name that would not fit")
      end

      it "returns first 30 characters of the attachment name" do
        is_expected.to eq("A very long file name that wou")
      end
    end

    context "with no attachment" do
      let(:attachment) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "#value" do
    subject { audio_ingredient.value }

    context "with attachment assigned" do
      it "returns attachment" do
        is_expected.to be(attachment)
      end
    end

    context "with no attachment assigned" do
      let(:attachment) { nil }

      it { is_expected.to be_nil }
    end
  end
end
