require 'spec_helper'

module Alchemy
  describe EssenceFile do

    let(:attachment) { build_stubbed(:attachment) }
    let(:essence)    { EssenceFile.new(attachment: attachment) }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceFile.new }
      let(:ingredient_value) { attachment }
    end

    describe '#preview_text' do

      it "returns the attachment's name as preview text" do
        expect(essence.preview_text).to eq(attachment.name)
      end

      context "with no attachment assigned" do
        it "returns empty string" do
          essence.attachment = nil
          expect(essence.preview_text).to eq('')
        end
      end
    end
  end
end
