require 'spec_helper'

describe Page do
	
	it "should get a webfriendly urlname on create" do
		page = Factory(:page, :name => 'klingon$&stößel ')
		page.urlname.should == 'klingon-stoessel'
	end
	
  it "should generate a three letter urlname from two letter name" do
    page = Factory(:page, :name => 'Au')
    page.urlname.should == '-au'
  end
  
  it "should generate a three letter urlname from two letter name with umlaut" do
    page = Factory(:page, :name => 'Aü')
    page.urlname.should == 'aue'
  end
  
  it "should generate a three letter urlname from one letter name" do
    page = Factory(:page, :name => 'A')
    page.urlname.should == '--a'
  end
  
	context "Root pages" do
		it "should contain one ore more rootpages" do
			Page.where(:parent_id => nil).any?
		end
	end
	
	context "with children" do
		before(:each) do
			@page = Factory(:page)
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