# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Video do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  let(:video_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "podcast",
      related_object: attachment
    )
  end

  describe "#allow_fullscreen" do
    subject { video_ingredient.allow_fullscreen }
    before { video_ingredient.allow_fullscreen = true }
    it { is_expected.to eq(true) }
  end

  describe "#autoplay" do
    subject { video_ingredient.autoplay }
    before { video_ingredient.autoplay = false }
    it { is_expected.to eq(false) }

    context "when set to '0'" do
      before { video_ingredient.autoplay = "0" }
      it { is_expected.to eq(false) }
    end

    context "when set to 't'" do
      before { video_ingredient.autoplay = "t" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#controls" do
    subject { video_ingredient.controls }
    before { video_ingredient.controls = true }
    it { is_expected.to eq(true) }

    context "when set to '0'" do
      before { video_ingredient.controls = "0" }
      it { is_expected.to eq(false) }
    end

    context "when set to 't'" do
      before { video_ingredient.controls = "t" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#height" do
    subject { video_ingredient.height }
    before { video_ingredient.height = 720 }
    it { is_expected.to eq(720) }
  end

  describe "#loop" do
    subject { video_ingredient.loop }
    before { video_ingredient.loop = false }
    it { is_expected.to eq(false) }

    context "when set to '0'" do
      before { video_ingredient.loop = "0" }
      it { is_expected.to eq(false) }
    end

    context "when set to 't'" do
      before { video_ingredient.loop = "t" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#muted" do
    subject { video_ingredient.muted }
    before { video_ingredient.muted = true }
    it { is_expected.to eq(true) }

    context "when set to '0'" do
      before { video_ingredient.muted = "0" }
      it { is_expected.to eq(false) }
    end

    context "when set to 't'" do
      before { video_ingredient.muted = "t" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#playsinline" do
    subject { video_ingredient.playsinline }
    before { video_ingredient.playsinline = true }
    it { is_expected.to eq(true) }

    context "when set to '0'" do
      before { video_ingredient.playsinline = "0" }
      it { is_expected.to eq(false) }
    end

    context "when set to 't'" do
      before { video_ingredient.playsinline = "t" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#preload" do
    subject { video_ingredient.preload }
    before { video_ingredient.preload = "auto" }
    it { is_expected.to eq("auto") }
  end

  describe "#width" do
    subject { video_ingredient.width }
    before { video_ingredient.width = 1280 }
    it { is_expected.to eq(1280) }
  end

  describe "#attachment" do
    subject { video_ingredient.attachment }

    it { is_expected.to be_an(Alchemy::Attachment) }
  end

  describe "#attachment=" do
    let(:attachment) { Alchemy::Attachment.new }

    subject { video_ingredient.attachment = attachment }

    it { is_expected.to be(attachment) }
  end

  describe "#attachment_id" do
    subject { video_ingredient.attachment_id }

    it { is_expected.to be_an(Integer) }
  end

  describe "#attachment_id=" do
    let(:attachment_id) { 111 }

    subject! { video_ingredient.attachment_id = attachment_id }

    it { expect(video_ingredient.related_object_id).to eq(111) }
    it { expect(video_ingredient.related_object_type).to eq("Alchemy::Attachment") }

    context "with nil passed as id" do
      let(:attachment_id) { nil }

      it "nullifies related_object_type" do
        expect(video_ingredient.related_object_type).to be_nil
      end
    end
  end

  describe "#preview_text" do
    subject { video_ingredient.preview_text }

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
    subject { video_ingredient.value }

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
