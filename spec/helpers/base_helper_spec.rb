require 'spec_helper'

describe Alchemy::BaseHelper do

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

	context "modules" do
		it "should render main navi entries for all core modules" do
			pending 'Do not know how to test helpers defined as helper_method in controller'
			helper.admin_main_navigation.should have_selector('a.main_navi_entry')
		end
	end

end
