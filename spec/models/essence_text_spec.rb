require 'spec_helper'

module Alchemy
  describe EssenceText do

    describe '.after_save' do
      let(:essence) { EssenceText.create }

      it "should update the value for `do_not_index`" do
        essence.stub(:description).and_return({'do_not_index' => true})
        essence.update_attributes(:body => 'hello')
        essence.do_not_index.should be_true
      end

      context "with `do_not_index` set to nil" do
        it "should update the value to false" do
          essence.stub(:description).and_return({'do_not_index' => nil})
          essence.update_attributes(:body => 'hello')
          essence.do_not_index.should_not be_nil
        end
      end
    end

    context "with `do_not_index` set to true" do
      it "should disable ferret indexing" do
        EssenceText.any_instance.stub(:description).and_return({'do_not_index' => true})
        essence = EssenceText.create!
        essence.ferret_enabled?.should be_false
      end
    end

    context "with `do_not_index` set to false" do
      it "should enable ferret indexing" do
        EssenceText.any_instance.stub(:description).and_return({'do_not_index' => false})
        essence = EssenceText.create
        essence.ferret_enabled?.should be_true
      end
    end

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
