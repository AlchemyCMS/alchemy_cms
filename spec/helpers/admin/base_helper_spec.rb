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

end
