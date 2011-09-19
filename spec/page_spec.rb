require 'spec_helper'

describe Page do
	
	it "should get a webfriendly urlname on create" do
		page = Factory(:page, :name => 'klingon$&stößel ')
		page.urlname.should == 'klingon-stoessel'
	end
	
	context "Root pages" do
		it "should contain one ore more rootpages" do
			Page.where(:parent_id => nil).any?
		end
	end
	
	context "with children" do
		before(:each) do
			@page = Factory(:page)
			puts @page.urlname
			@first_child = Factory(:page, :name => "First child", :language => @page.language, :public => false)
			@first_child.move_to_child_of(@page)
			
			@first_public_child = Factory(:page, :name => "First public child", :language => @page.language, :public => true)
			@first_public_child.move_to_child_of(@page)
		end
		
		it "should return a page object (or nil if no public children exists) for first_public_child" do
			if @page.children.any?
				@page.first_public_child.should == @first_public_child
			else
				@page.first_public_child.should == nil
			end
		end
	end
	
end