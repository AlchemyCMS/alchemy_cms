require 'spec_helper'

module Alchemy
  describe Admin::TagsHelper do

    let(:tag) do
      mock_model(ActsAsTaggableOn::Tag, :name => "foo")
    end

    describe "#filtered_by_tag?" do
      it "should return true if the filterlist contains the given tag" do
        controller.params[:tagged_with] = "foo,bar,baz"
        helper.filtered_by_tag?(tag).should == true
      end

      it "should return false if the filterlist does not contain the given tag" do
        controller.params[:tagged_with] = "bar,baz"
        helper.filtered_by_tag?(tag).should == false
      end
    end

    describe "#add_to_tag_filter" do
      context "if params[:tagged_with] is not present" do
        it "should return an Array with the given tag name" do
          helper.add_to_tag_filter(tag).should == ["foo"]
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        it "should return an Array of tag names including the given one" do
          controller.params[:tagged_with] = "bar,baz"
          helper.add_to_tag_filter(tag).should == ["bar", "baz", "foo"]
        end
      end
    end

    describe "#remove_from_tag_filter" do
      context "if params[:tagged_with] is not present" do
        it "should return an empty Array" do
          helper.remove_from_tag_filter(tag).should be_empty
        end
      end

      context "if params[:tagged_with] contains some tag names" do
        it "should return an Array of tag names without the given one" do
          controller.params[:tagged_with] = "bar,baz,foo"
          helper.remove_from_tag_filter(tag).should == ["bar", "baz"]
        end
      end
    end

  end
end