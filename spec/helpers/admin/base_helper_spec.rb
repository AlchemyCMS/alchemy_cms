require 'spec_helper'

describe Alchemy::Admin::BaseHelper do

  context "maximum amount of images option" do

    before(:each) do
      @options = {}
    end

    context "with max_images option" do

      it "should return nil for empty string" do
        @options[:max_images] = ""
        max_image_count.should be(nil)
      end

      it "should return an integer for string number" do
        @options[:max_images] = "1"
        max_image_count.should be(1)
      end

    end

    context "with maximum_amount_of_images option" do

      it "should return nil for empty string" do
        @options[:maximum_amount_of_images] = ""
        max_image_count.should be(nil)
      end

      it "should return an integer for string number" do
        @options[:maximum_amount_of_images] = "1"
        max_image_count.should be(1)
      end

    end

  end

  describe "#merge_params" do
    before(:each) do
      controller.stub!(:params).and_return({:first => '1', :second => '2'})
    end

    it "returns a hash that contains the current params and additional params given as attributes" do
      helper.merge_params(:third => '3', :fourth => '4').should == {:first => '1', :second => '2', :third => '3', :fourth => '4'}
    end
  end

  describe "#merge_params_without" do
    before(:each) do
      controller.stub!(:params).and_return({:first => '1', :second => '2'})
    end
    it "can delete a single param" do
      helper.merge_params_without(:second).should == {:first => '1'}
    end

    it "can delete several params" do
      helper.merge_params_without([:first, :second]).should == {}
    end

    it "can delete a param and add new params at the same time" do
      helper.merge_params_without([:first], {:third => '3'}).should == {:second => '2', :third => '3'}
    end

    it "should not change params" do
      helper.merge_params_without([:first])
      controller.params.should == {:first => '1', :second => '2'}
    end
  end

end
