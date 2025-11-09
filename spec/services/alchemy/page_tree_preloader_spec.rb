# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PageTreePreloader do
  let(:user) { create(:alchemy_dummy_user) }
  let(:root_page) { create(:alchemy_page, :language_root) }
  let!(:child_page_1) { create(:alchemy_page, parent: root_page) }
  let!(:child_page_2) { create(:alchemy_page, parent: root_page) }
  let!(:grandchild_page) { create(:alchemy_page, parent: child_page_1) }

  describe "#call" do
    # Reload root_page to ensure nested set values are current
    # (they become stale after children are added)
    subject { described_class.new(page: root_page.reload, user: user).call }

    it "returns root page" do
      expect(subject).to eq(root_page)
    end

    it "preloads children association" do
      expect(subject.association(:children)).to be_loaded
    end

    it "preloads children in correct tree order" do
      expect(subject.children).to eq([child_page_1, child_page_2])
    end

    it "preloads grandchildren" do
      expect(subject.children.first.children).to eq([grandchild_page])
    end

    it "preloads public_version association" do
      expect(subject.association(:public_version)).to be_loaded
    end

    it "preloads language and site associations" do
      expect(subject.association(:language)).to be_loaded
      expect(subject.language.association(:site)).to be_loaded
    end

    context "with folded pages" do
      before do
        child_page_1.fold!(user.id, true)
      end

      it "does not include children of folded pages" do
        expect(subject.children.first.children).to eq([])
      end

      it "still returns the folded page itself" do
        expect(subject.children).to include(child_page_1)
      end
    end

    context "without user" do
      subject { described_class.new(page: root_page.reload).call }

      it "returns pages with all children loaded" do
        expect(subject.children.first.children).to eq([grandchild_page])
      end
    end
  end
end
