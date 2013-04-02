require 'spec_helper'

module Alchemy
  describe Admin::BaseHelper do

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

    describe '#pages_for_select' do

      let(:contact_form) { FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true) }
      let(:page_a) { FactoryGirl.create(:public_page, :name => 'Page A') }
      let(:page_b) { FactoryGirl.create(:public_page, :name => 'Page B') }
      let(:page_c) { FactoryGirl.create(:public_page, :name => 'Page C', :parent_id => page_b.id) }

      before do
        # to be shure the ordering is alphabetic
        page_b
        page_a
        helper.session[:language_id] = 1
      end

      context "with no arguments given" do

        it "should return options for select with all pages ordered by lft" do
          helper.pages_for_select.should match(/option.*Page B.*Page A/m)
        end

        it "should return options for select with nested page names" do
          page_c
          output = helper.pages_for_select
          output.should match(/option.*Startseite.*>&nbsp;&nbsp;Page B.*>&nbsp;&nbsp;&nbsp;&nbsp;Page C.*>&nbsp;&nbsp;Page A/m)
        end

      end

      context "with pages passed in" do

        before do
          @pages = []
          3.times { @pages << FactoryGirl.create(:public_page) }
        end

        it "should return options for select with only these pages" do
          output = helper.pages_for_select(@pages)
          output.should match(/#{@pages.collect(&:name).join('.*')}/m)
          output.should_not match(/Page A/m)
        end

        it "should not nest the page names" do
          output = helper.pages_for_select(@pages)
          output.should_not match(/option.*&nbsp;/m)
        end

      end

    end

  end
end
