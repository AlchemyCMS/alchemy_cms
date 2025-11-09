# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PageTreePreloader do
  let(:language) { create(:alchemy_language, :german, default: true) }
  let(:user) { create(:alchemy_dummy_user) }
  let!(:root_page) { create(:alchemy_page, :language_root, language: language) }
  let!(:child_page_1) { create(:alchemy_page, parent: root_page, language: language) }
  let!(:child_page_2) { create(:alchemy_page, parent: root_page, language: language) }
  let!(:grandchild_page) { create(:alchemy_page, parent: child_page_1, language: language) }
  let!(:layoutpage) { create(:alchemy_page, :layoutpage, language: language) }

  describe "#call" do
    subject { described_class.new(language: language, user: user).call }

    it "returns only root pages" do
      expect(subject).to eq([root_page])
    end

    it "does not include layout pages" do
      expect(subject).to_not include(layoutpage)
    end

    it "preloads children association" do
      result = subject.first
      expect(result.association(:children)).to be_loaded
    end

    it "preloads children in correct tree order" do
      result = subject.first
      expect(result.children).to eq([child_page_1, child_page_2])
    end

    it "preloads grandchildren" do
      result = subject.first
      expect(result.children.first.children).to eq([grandchild_page])
    end

    it "preloads public_version association" do
      result = subject.first
      expect(result.association(:public_version)).to be_loaded
    end

    it "preloads language and site associations" do
      result = subject.first
      expect(result.association(:language)).to be_loaded
      expect(result.language.association(:site)).to be_loaded
    end

    context "without language parameter" do
      subject { described_class.new(user: user).call }

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with("Neither a start page not language given! Skipping preloading pages.")
        subject
      end

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

    context "with folded pages" do
      before do
        child_page_1.fold!(user.id, true)
      end

      it "does not include children of folded pages" do
        result = subject.first
        expect(result.children.first.children).to eq([])
      end

      it "still returns the folded page itself" do
        result = subject.first
        expect(result.children).to include(child_page_1)
      end
    end

    context "without user" do
      subject { described_class.new(language: language).call }

      it "returns pages with all children loaded" do
        result = subject.first
        expect(result.children.first.children).to eq([grandchild_page])
      end
    end

    context "with multiple languages" do
      let(:klingon) { create(:alchemy_language, :klingon) }
      let!(:klingon_root) { create(:alchemy_page, :language_root, language: klingon) }
      let!(:klingon_child) { create(:alchemy_page, parent: klingon_root, language: klingon) }

      it "only returns pages for the specified language" do
        result = described_class.new(language: language, user: user).call
        all_pages = [result, *result.flat_map(&:children)].flatten
        expect(all_pages).to_not include(klingon_root, klingon_child)
      end
    end

    context "with from parameter" do
      subject { described_class.new(from: root_page, user: user).call }

      it "returns an array with one page" do
        expect(subject).to be_an(Array)
        expect(subject.size).to eq(1)
      end

      it "returns the page with same id" do
        expect(subject.first.id).to eq(root_page.id)
      end

      it "preloads children association" do
        expect(subject.first.association(:children)).to be_loaded
      end

      # Note: The detailed assertions about children content are covered by
      # the controller integration tests which prove the preloading works correctly
    end
  end
end
