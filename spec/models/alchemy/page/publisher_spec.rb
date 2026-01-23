# frozen_string_literal: true

require "rails_helper"
require "timecop"

RSpec.describe Alchemy::Page::Publisher do
  describe "#publish!" do
    let(:current_time) { Time.current.change(usec: 0) }
    let(:page) do
      create(:alchemy_page,
        public_on: public_on,
        public_until: public_until,
        published_at: published_at)
    end
    let(:published_at) { nil }
    let(:public_on) { nil }
    let(:public_until) { nil }
    let(:publisher) { described_class.new(page) }

    subject(:publish) { publisher.publish!(public_on: current_time) }

    around do |example|
      Timecop.freeze(current_time) do
        example.run
      end
    end

    shared_context "with elements" do
      let(:page) do
        create(:alchemy_page, autogenerate_elements: true).tap do |page|
          page.draft_version.elements.first.update!(public: false)
        end
      end
    end

    it "creates a public version" do
      expect { publish }.to change { page.versions.published.count }.by(1)
    end

    it "updates the public_on timestamp" do
      expect {
        publish
      }.to change {
        page.reload.public_on
      }.to(current_time)
    end

    context "with elements" do
      include_context "with elements"

      it "copies all published elements to page version" do
        publish
        expect(page.reload.public_version.elements.count).to eq(2)
      end
    end

    context "with elements scheduled for future publication" do
      let(:page) { create(:alchemy_page) }

      let!(:current_element) do
        create(:alchemy_element,
          page_version: page.draft_version,
          public_on: 1.day.ago)
      end

      let!(:future_element) do
        create(:alchemy_element,
          page_version: page.draft_version,
          public_on: 1.day.from_now)
      end

      let!(:draft_element) do
        create(:alchemy_element, page_version: page.draft_version).tap do |element|
          element.update_columns(public_on: nil)
        end
      end

      let!(:expired_element) do
        create(:alchemy_element,
          page_version: page.draft_version,
          public_on: 2.days.ago,
          public_until: 1.day.ago)
      end

      it "copies currently public and future scheduled elements" do
        publish
        expect(page.reload.public_version.elements.count).to eq(2)
      end

      it "does not copy draft elements without public_on" do
        publish
        public_ons = page.reload.public_version.elements.pluck(:public_on)
        expect(public_ons).to all(be_present)
      end

      it "does not copy expired elements" do
        publish
        public_untils = page.reload.public_version.elements.pluck(:public_until)
        expect(public_untils).to all(be_nil)
      end
    end

    context "with draft version metadata" do
      before do
        page.draft_version.update!(
          title: "Draft Title",
          meta_description: "Draft description",
          meta_keywords: "draft, keywords"
        )
      end

      it "copies metadata from draft_version to public_version" do
        publish
        page.reload
        expect(page.public_version.title).to eq("Draft Title")
        expect(page.public_version.meta_description).to eq("Draft description")
        expect(page.public_version.meta_keywords).to eq("draft, keywords")
      end
    end

    context "with published version existing" do
      let(:yesterday) { Date.yesterday.to_time }
      let!(:public_version) do
        create(:alchemy_page_version, :with_elements, element_count: 3, public_on: yesterday, page: page)
      end

      let!(:nested_element) do
        create(:alchemy_element, page_version: public_version, parent_element: public_version.elements.first)
      end

      it "does not change current public versions public on date" do
        expect { publish }.to_not change(page.public_version, :public_on)
      end

      it "updates public version's updated_at timestamp" do
        # Need to do this here, because the nested element touches the version on creation.
        public_version.update_columns(updated_at: yesterday)
        expect { publish }.to change(page.public_version, :updated_at)
      end

      it "does not create another public version" do
        expect { publish }.to_not change(page.versions, :count)
      end

      context "with elements" do
        include_context "with elements"

        it "copies all published elements to public version" do
          publish
          expect(public_version.reload.elements.count).to eq(2)
        end
      end
    end

    context "with publish targets" do
      # This job _actually_ runs the Publisher, which then triggers the publish targets.
      # Just using it here because it has the same method signature as a Publish Target,
      # and stubbing "constantize" is not easy.
      let(:target_class_name) { "Alchemy::PublishPageJob" }

      around do |example|
        Alchemy.config.publish_targets << target_class_name
        example.run
        Alchemy.config.publish_targets = []
      end

      it "performs each target" do
        expect(Alchemy::PublishPageJob).to receive(:perform_later).with(page)
        publish
      end
    end

    context "with nested elements" do
      let(:page) { create(:alchemy_page) }

      let!(:parent_element) do
        create(:alchemy_element, page_version: page.draft_version, public: true)
      end

      let!(:visible_nested) do
        create(:alchemy_element, parent_element: parent_element, page_version: page.draft_version, public: true)
      end

      let!(:hidden_nested) do
        create(:alchemy_element, parent_element: parent_element, page_version: page.draft_version, public: false)
      end

      it "copies only visible nested elements to public version" do
        publish
        published_parent = page.reload.public_version.elements.first
        expect(published_parent.all_nested_elements).to all(be_public)
      end
    end

    context "in parallel" do
      before do
        # another publisher - instance created a mutex entry and locked the page
        Alchemy::PageMutex.create(page: page, created_at: 5.seconds.ago)
      end

      it "fails, if another process locked the page" do
        expect { publish }.to raise_error Alchemy::PageMutex::LockFailed
      end

      context "another page" do
        let(:another_page) { create(:alchemy_page) }
        let(:publisher) { described_class.new(another_page) }

        it "should allow the publishing of another page" do
          expect { publish }.to change { another_page.versions.published.count }.by(1)
        end
      end
    end
  end
end
