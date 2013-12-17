require 'spec_helper'

module Alchemy
  describe EssenceFile do

    describe '#attachment_url' do
      subject { essence.attachment_url }

      let(:attachment) { build_stubbed(:attachment) }
      let(:essence)    { build_stubbed(:essence_file, attachment: attachment) }

      it "returns the download attachment url." do
        should match(/\/attachment\/#{attachment.id}\/download\/#{attachment.file_name}/)
      end

      context 'without attachment assigned' do
        let(:attachment) { nil }

        it { should be_nil }
      end
    end

    describe '#preview_text' do
      let(:attachment) { mock_model(Attachment, name: 'File') }
      let(:essence) { EssenceFile.new }

      it "returns the attachment's name as preview text" do
        essence.stub(:attachment).and_return(attachment)
        essence.preview_text.should == 'File'
      end

      context "with no attachment assigned" do
        it "returns empty string" do
          essence.preview_text.should == ''
        end
      end
    end

  end
end
