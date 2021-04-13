# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PublishPageJob, type: :job do
  describe "#perfom_later" do
    let(:page) { build_stubbed(:alchemy_page) }
    let(:public_on) { Time.current }

    it "enqueues job" do
      expect {
        described_class.perform_later(page, public_on: public_on)
      }.to have_enqueued_job
    end

    it "calls the page publisher" do
      expect_any_instance_of(Alchemy::Page::Publisher).to receive(:publish!).with(
        public_on: public_on,
      )
      described_class.new.perform(page, public_on: public_on)
    end
  end
end
