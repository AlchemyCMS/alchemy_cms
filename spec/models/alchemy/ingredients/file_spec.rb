# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::File do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  let(:file_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "download",
      related_object: attachment,
    )
  end

  describe "css_class" do
    before { file_ingredient.css_class = "download" }
    subject { file_ingredient.css_class }

    it { is_expected.to eq("download") }
  end

  describe "link_text" do
    before { file_ingredient.link_text = "Download" }
    subject { file_ingredient.link_text }

    it { is_expected.to eq("Download") }
  end

  describe "title" do
    before { file_ingredient.title = "Click to download" }
    subject { file_ingredient.title }

    it { is_expected.to eq("Click to download") }
  end

  describe "attachment" do
    subject { file_ingredient.attachment }

    it { is_expected.to be_an(Alchemy::Attachment) }
  end

  describe "attachment=" do
    let(:attachment) { Alchemy::Attachment.new }

    subject { file_ingredient.attachment = attachment }

    it { is_expected.to be(attachment) }
  end

  describe "#attachment_id" do
    subject { file_ingredient.attachment_id }

    it {
      is_expected.to be_an(Integer)
    }
  end

  describe "#attachment_id=" do
    let(:attachment) { Alchemy::Attachment.new(id: 111) }

    subject { file_ingredient.attachment_id = attachment.id }

    it { is_expected.to be(111) }
    it { expect(file_ingredient.related_object_type).to eq("Alchemy::Attachment") }
  end

  describe "preview_text" do
    subject { file_ingredient.preview_text }

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

  describe "value" do
    subject { file_ingredient.value }

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
