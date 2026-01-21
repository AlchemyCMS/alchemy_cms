# frozen_string_literal: true

require "rails_helper"
require "alchemy/test_support/shared_publishable_examples"

describe Alchemy::PageVersion do
  it { is_expected.to belong_to(:page) }
  it { is_expected.to have_many(:elements) }

  it { is_expected.to have_db_column(:title).of_type(:string) }
  it { is_expected.to have_db_column(:meta_description).of_type(:text) }
  it { is_expected.to have_db_column(:meta_keywords).of_type(:text) }

  let(:page) { create(:alchemy_page) }

  it_behaves_like("being publishable", :alchemy_page_version)

  describe "when saved" do
    let(:page_version) { build(:alchemy_page_version) }
    let(:page) { page_version.page }

    it "touches the page" do
      expect { page_version.save }.to change(page, :updated_at)
    end
  end

  describe "#set_title_from_page" do
    let(:page) { create(:alchemy_page, name: "My Page Name") }

    context "when title is blank" do
      it "sets title from page name" do
        page_version = page.versions.create!(title: nil)
        expect(page_version.title).to eq("My Page Name")
      end

      it "sets title from page name when title is empty string" do
        page_version = page.versions.create!(title: "")
        expect(page_version.title).to eq("My Page Name")
      end
    end

    context "when title is already set" do
      it "does not override the title" do
        page_version = page.versions.create!(title: "Custom Title")
        expect(page_version.title).to eq("Custom Title")
      end
    end
  end

  describe "dependent element destruction" do
    let!(:parent_element) { create(:alchemy_element, :with_nestable_elements, :with_ingredients) }
    let!(:nested_element) { parent_element.nested_elements.first }
    let!(:normal_element) { create(:alchemy_element, :with_ingredients) }

    let(:page_version) { create(:alchemy_page_version) }

    before do
      Alchemy::Element.update_all(page_version_id: page_version.id)
    end

    it "deletes all elements along with the page version" do
      page_version.destroy!
      expect(Alchemy::Element.count).to be_zero
      expect(Alchemy::Ingredient.count).to be_zero
    end
  end

  describe "#element_repository" do
    let(:page_version) { create(:alchemy_page_version, :with_elements) }
    subject { page_version.element_repository }

    it "is an element repository containing the pages elements" do
      expect(Alchemy::ElementsRepository).to receive(:new).with(page_version.elements).and_call_original
      expect(subject).to be_a(Alchemy::ElementsRepository)
    end
  end
end
