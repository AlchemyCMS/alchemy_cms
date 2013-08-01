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
        controller.stub(:params).and_return({:first => '1', :second => '2'})
      end

      it "returns a hash that contains the current params and additional params given as attributes" do
        helper.merge_params(:third => '3', :fourth => '4').should == {:first => '1', :second => '2', :third => '3', :fourth => '4'}
      end
    end

    describe "#merge_params_without" do
      before(:each) do
        controller.stub(:params).and_return({:first => '1', :second => '2'})
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
        controller.stub(:params).and_return({:first => '1', :second => '2', :third => '3'})
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

    describe '#toolbar_button' do
      context "with permission" do
        before {
          helper.stub(:can?).and_return(true)
        }

        it "renders a toolbar button" do
          helper.toolbar_button(
            url: admin_users_path
          ).should match /<div.+class="button_with_label/
        end
      end

      context "without permission" do
        before {
          helper.stub(:can?).and_return(false)
        }

        it "returns empty string" do
          helper.toolbar_button(
            url: admin_users_path
          ).should be_empty
        end
      end

      context "with disabled permission check" do
        before {
          helper.stub(:can?).and_return(false)
        }

        it "returns the button" do
          helper.toolbar_button(
            url: admin_users_path,
            skip_permission_check: true
          ).should match /<div.+class="button_with_label/
        end
      end

      context "with empty permission option" do
        before {
          helper.stub(:can?).and_return(true)
        }

        it "returns reads the permission from url" do
          helper.should_receive(:permission_array_from_url)
          helper.toolbar_button(
            url: admin_users_path,
            if_permitted_to: ''
          ).should_not be_empty
        end
      end

      context "with overlay option set to false" do
        before {
          helper.stub(:can?).and_return(true)
          helper.should_receive(:permission_array_from_url)
        }

        it "renders a normal link" do
          button = helper.toolbar_button(
            url: admin_users_path,
            overlay: false
          )
          button.should match /<a.+href="#{admin_users_path}"/
          button.should_not match /data-alchemy-overlay/
        end
      end
    end

  end
end
