require 'spec_helper'

module Alchemy
  describe EssenceFile do

    let(:attachment) { build_stubbed(:attachment) }
    let(:essence)    { EssenceFile.new(attachment: attachment) }

    it_behaves_like "an essence" do
      let(:essence)          { EssenceFile.new }
      let(:ingredient_value) { attachment }
    end

    describe '#attachment_url' do
      subject { essence.attachment_url }

      it "returns the download attachment url." do
        should match(/\/attachment\/#{attachment.id}\/download\/#{attachment.file_name}/)
      end

      context 'without attachment assigned' do
        let(:attachment) { nil }

        it { should be_nil }
      end
    end

    describe '#preview_text' do

      it "returns the attachment's name as preview text" do
        essence.preview_text.should == attachment.name
      end

      context "with no attachment assigned" do
        it "returns empty string" do
          essence.attachment = nil
          essence.preview_text.should == ''
        end
      end
    end

  end
end
