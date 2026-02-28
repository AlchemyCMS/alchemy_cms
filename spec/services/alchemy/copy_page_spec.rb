# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::CopyPage do
  let(:page) { create(:alchemy_page) }
  let(:changed_attributes) { {} }

  subject(:copy_page) { described_class.new(page: page).call(changed_attributes: changed_attributes) }

  it "the copy should have added (copy) to name" do
    expect(subject.name).to eq("#{page.name} (Copy)")
  end

  it "the copy should have one draft version" do
    expect(subject.versions.length).to eq(1)
    expect(subject.draft_version).to be
  end

  context "a public page" do
    let(:page) { create(:alchemy_page, :public, name: "Source", public_until: Time.current) }

    it "the copy should not be public" do
      expect(subject.public_on).to be(nil)
      expect(subject.public_until).to be(nil)
    end
  end

  context "a locked page" do
    let(:page) do
      create(:alchemy_page, :public, :locked, name: "Source")
    end

    it "the copy should not be locked" do
      expect(subject.locked?).to be(false)
      expect(subject.locked_by).to be(nil)
    end
  end

  context "page with tags" do
    before do
      page.tag_list = "red, yellow"
      page.save!
    end

    it "the copy should have source tag_list" do
      expect(subject.tag_list).not_to be_empty
      expect(subject.tag_list).to match_array(page.tag_list)
    end
  end

  context "page with elements" do
    before { create(:alchemy_element, page: page, page_version: page.draft_version) }

    it "the copy should have source elements on its draft version" do
      expect(subject.draft_version.elements).not_to be_empty
      expect(subject.draft_version.elements.count).to eq(page.draft_version.elements.count)
    end
  end

  context "page with metadata" do
    before do
      page.draft_version.update!(
        title: "Source Title",
        meta_description: "Source description",
        meta_keywords: "source, keywords"
      )
    end

    it "copies meta_description and meta_keywords to the new page's draft version" do
      expect(subject.draft_version.meta_description).to eq("Source description")
      expect(subject.draft_version.meta_keywords).to eq("source, keywords")
    end

    it "copies the title from the source page's draft version" do
      expect(subject.draft_version.title).to eq("Source Title")
    end
  end

  context "page with fixed elements" do
    before { create(:alchemy_element, :fixed, page: page, page_version: page.draft_version) }

    it "the copy should have source fixed elements on its draft version" do
      expect(subject.draft_version.elements.fixed).not_to be_empty
      expect(subject.draft_version.elements.fixed.count).to eq(page.draft_version.elements.fixed.count)
    end
  end

  context "page with autogenerate elements" do
    before do
      page = create(:alchemy_page)
      allow(page).to receive(:definition).and_return({
        "name" => "standard",
        "elements" => ["headline"],
        "autogenerate" => ["headline"]
      })
    end

    it "the copy should not autogenerate elements" do
      expect(subject.draft_version.elements).to be_empty
    end
  end

  context "with different page name given" do
    let(:changed_attributes) { {name: "Different name"} }

    it "should take this name" do
      expect(subject.name).to eq("Different name")
    end

    it "keeps the draft version title from the source page" do
      expect(subject.draft_version.title).to eq(page.draft_version.title)
    end
  end

  context "with exceptions during copy" do
    before do
      expect(Alchemy::Page).to receive(:copy_elements) { raise "boom" }
    end

    it "rolls back all changes" do
      page
      expect {
        expect { Alchemy::Page.copy(page, {name: "Different name"}) }.to raise_error("boom")
      }.to_not change(Alchemy::Page, :count)
    end
  end

  context "copying a different parent" do
    let(:original_parent) { create(:alchemy_page) }
    let(:page) { create(:alchemy_page, parent: original_parent) }
    let(:destination) { create(:alchemy_page) }
    let(:changed_attributes) { {parent_id: destination.id} }

    it "should not add (copy) to name" do
      expect(subject.name).to eq(page.name)
    end
  end
end
