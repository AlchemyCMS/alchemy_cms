# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::StorePictureThumbJob, type: :job do
  let(:thumb) { build_stubbed(:alchemy_picture_thumb) }
  let(:uid) { "pictures/1234/abcd/name.png" }

  it "enqueues job" do
    thumb
    expect {
      described_class.perform_later(thumb, uid)
    }.to have_enqueued_job
  end

  describe "#perform" do
    subject(:perform) { described_class.new.perform(thumb, uid) }

    it "calls the storage class" do
      expect(Alchemy::PictureThumb.storage_class).to receive(:call).with(
        an_instance_of(Alchemy::PictureVariant),
        uid
      )
      perform
    end

    context "on processing errors" do
      let!(:thumb) { create(:alchemy_picture_thumb) }

      before do
        expect(Alchemy::PictureThumb.storage_class).to receive(:call) do
          raise(Dragonfly::Job::Fetch::NotFound)
        end
      end

      it "calls the error tracking handler" do
        expect(Alchemy::ErrorTracking.notification_handler).to receive(:call)
        perform
      end

      it "destroys thumbnail" do
        expect { subject }.to change { thumb.picture.thumbs.reload.length }.from(4).to(3)
      end
    end

    context "on file errors" do
      let!(:thumb) { create(:alchemy_picture_thumb) }

      before do
        expect(Alchemy::PictureThumb.storage_class).to receive(:call) do
          raise("Bam!")
        end
      end

      it "calls the error tracking handler" do
        expect(Alchemy::ErrorTracking.notification_handler).to receive(:call)
        perform
      end

      it "destroys thumbnail" do
        expect { subject }.to change { thumb.picture.thumbs.reload.length }.from(4).to(3)
      end
    end
  end
end
