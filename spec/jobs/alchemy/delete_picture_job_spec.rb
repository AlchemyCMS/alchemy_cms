require "rails_helper"

RSpec.describe Alchemy::DeletePictureJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(5) }

    context "when picture exists" do
      let(:picture) { build(:alchemy_picture) }

      before do
        allow(Alchemy::Picture).to receive(:find_by).with(id: 5) { picture }
      end

      context "when picture is deletable" do
        it "deletes the picture" do
          expect(picture).to receive(:deletable?) { true }
          expect(picture).to receive(:destroy)
          perform
        end
      end

      context "when picture is not deletable" do
        it "does not delete the picture" do
          expect(picture).to receive(:deletable?) { false }
          expect(picture).to_not receive(:destroy)
          perform
        end
      end
    end

    context "when picture does not exist" do
      before do
        allow(Alchemy::Picture).to receive(:find_by).with(id: 5) { nil }
      end

      it "does nothing" do
        perform
      end
    end
  end
end
