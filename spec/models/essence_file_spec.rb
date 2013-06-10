require 'spec_helper'

module Alchemy
  describe EssenceFile do

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
