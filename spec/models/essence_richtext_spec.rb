require 'spec_helper'

module Alchemy
  describe EssenceRichtext do

    it "should save a HTML tag free version of body column" do
      essence = EssenceRichtext.new(:body => '<h1>Hello!</h1><p>Welcome to Peters Petshop.</p>')
      essence.save
      essence.stripped_body.should == "Hello!Welcome to Peters Petshop."
    end

    describe '.after_save' do
      let(:essence) { EssenceRichtext.create }

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
        EssenceRichtext.any_instance.stub(:description).and_return({'do_not_index' => true})
        essence = EssenceRichtext.create
        essence.ferret_enabled?.should be_false
      end
    end

    context "with `do_not_index` set to false" do
      it "should enable ferret indexing" do
        EssenceRichtext.any_instance.stub(:description).and_return({'do_not_index' => false})
        essence = EssenceRichtext.create
        essence.ferret_enabled?.should be_true
      end
    end

  end
end
