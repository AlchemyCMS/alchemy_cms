require 'spec_helper'

module Alchemy
  module Admin

    describe BaseHelper do

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

      describe "#merge_params_only" do

        before(:each) do
          controller.stub!(:params).and_return({:first => '1', :second => '2', :third => '3'})
        end

        it "can keep a single param" do
          helper.merge_params_only(:second).should == {:second => '2'}
        end

        it "can keep several params" do
          helper.merge_params_only([:first, :second]).should == {:first => '1', :second => '2'}
        end

        it "can keep a param and add new params at the same time" do
          helper.merge_params_only([:first], {:third => '3'}).should == {:first => '1', :third => '3'}
        end

        it "should not change params" do
          helper.merge_params_only([:first])
          controller.params.should == {:first => '1', :second => '2', :third => '3'}
        end

      end

      context "Filtering pictures depending on tags from params" do

        let(:tag) do
          mock_model(ActsAsTaggableOn::Tag, :name => "foo")
        end

        describe "#pictures_filtered_by_tag?" do
          it "should return true if the filterlist contains the given tag" do
            controller.params[:tagged_with] = "foo,bar,baz"
            helper.pictures_filtered_by_tag?(tag).should == true
          end

          it "should return false if the filterlist does not contain the given tag" do
            controller.params[:tagged_with] = "bar,baz"
            helper.pictures_filtered_by_tag?(tag).should == false
          end
        end

        describe "#add_to_picture_tag_filter" do
          context "if params[:tagged_with] is not present" do
            it "should return an Array with the given tag name" do
              helper.add_to_picture_tag_filter(tag).should == ["foo"]
            end
          end

          context "if params[:tagged_with] contains some tag names" do
            it "should return an Array of tag names including the given one" do
              controller.params[:tagged_with] = "bar,baz"
              helper.add_to_picture_tag_filter(tag).should == ["bar", "baz", "foo"]
            end
          end
        end

        describe "#remove_from_picture_tag_filter" do
          context "if params[:tagged_with] is not present" do
            it "should return an empty Array" do
              helper.remove_from_picture_tag_filter(tag).should be_empty
            end
          end

          context "if params[:tagged_with] contains some tag names" do
            it "should return an Array of tag names without the given one" do
              controller.params[:tagged_with] = "bar,baz,foo"
              helper.remove_from_picture_tag_filter(tag).should == ["bar", "baz"]
            end
          end
        end

      end

    end

  end
end
