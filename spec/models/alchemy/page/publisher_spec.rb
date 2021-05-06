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

    context "with elements" do
      include_context "with elements"

      it "copies all published elements to page version" do
        publish
        expect(page.reload.public_version.elements.count).to eq(2)
      end
    end

    context "with published version existing" do
      let!(:public_version) do
        create(:alchemy_page_version, :with_elements, element_count: 3, public_on: Date.yesterday.to_time, page: page)
      end

      let!(:nested_element) do
        create(:alchemy_element, page_version: public_version, parent_element: public_version.elements.first)
      end

      it "does not change current public versions public on date" do
        expect { publish }.to_not change(page.public_version, :public_on)
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
      let(:target) { Class.new(ActiveJob::Base) }

      around do |example|
        Alchemy.publish_targets << target
        example.run
        Alchemy.instance_variable_set(:@_publish_targets, nil)
      end

      it "performs each target" do
        expect(target).to receive(:perform_later).with(page)
        publish
      end
    end
  end
end
