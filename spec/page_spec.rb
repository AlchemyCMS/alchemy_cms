require 'spec_helper'

describe Page do
	context "having a first public child" do
		
		before(:each) do
			@page = Factory(:public_page)
			@public_child = Factory.build(:public_page)
			@public_child.name = "First child"
			@public_child.move_to_child_of(@page)
		end
		
		it "should return a page object" do
			@page.first_public_child.should be(@public_child)
		end
	end
end