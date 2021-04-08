# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::File do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:attachment) { build(:alchemy_attachment) }

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
end
