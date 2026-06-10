require "rails_helper"

RSpec.describe Alchemy::InvalidateElementsCacheJob, type: :job do
  let(:job) { described_class.new }

  subject { job.perform("Alchemy::Page", related_object.id) }

  let(:page) { create(:alchemy_page, :public, updated_at: 1.week.ago) }

  let!(:element) do
    create(:alchemy_element, page_version: page.draft_version, ingredients: [ingredient], updated_at: 1.day.ago)
  end

  describe "#perform" do
    let(:related_object) { create(:alchemy_page) }
    let(:ingredient) { Alchemy::Ingredients::Page.create(related_object:, role: "page") }

    it "touches the element" do
      expect { subject }.to change { element.reload.updated_at }
    end

    context "when the element has a parent" do
      let!(:parent_element) do
        create(:alchemy_element, page_version: page.draft_version, updated_at: 1.day.ago).tap do |parent|
          element.update_column(:parent_element_id, parent.id)
        end
      end

      it "touches the parent element" do
        expect { subject }.to change { parent_element.reload.updated_at }
      end

      context "that has a parent" do
        let!(:grand_parent_element) do
          create(:alchemy_element, page_version: page.draft_version, updated_at: 1.day.ago).tap do |grand_parent|
            parent_element.update_column(:parent_element_id, grand_parent.id)
          end
        end

        it "touches the grand parent element" do
          expect { subject }.to change { grand_parent_element.reload.updated_at }
        end
      end
    end

    it "touches the page" do
      expect { subject }.to change { page.reload.updated_at }
    end
  end
end
