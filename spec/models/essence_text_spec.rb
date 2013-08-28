require 'spec_helper'

module Alchemy
  describe EssenceText do

    context "acts_as_essence methods" do

      describe '#preview_text' do
        let(:essence) { EssenceText.new(body: 'Lorem ipsum') }

        it "should return a preview text" do
          essence.preview_text.should == 'Lorem ipsum'
        end

        context "with maxlength of 2" do
          it "should return very short preview text" do
            essence.preview_text(2).should == 'Lo'
          end
        end

        context "with another preview_text_column defined" do
          before {
            essence.stub(:title).and_return('Title column')
            essence.stub(:preview_text_column).and_return(:title)
          }

          it "should use this column as preview text method" do
            essence.preview_text.should == 'Title column'
          end
        end
      end

    end

  end
end
