require 'spec_helper'

describe Page do
	
	before(:each) do
		@rootpage = Factory(:page, :page_layout => "rootpage", :parent_id => nil)
		@language = @rootpage.language
		@language_root = Factory(:page, :parent_id => @rootpage.id, :language => @language)
	end
	
	context "create" do
		it "the rootpage with page_layout rootpage does not need a parent_id" do
			@rootpage.rootpage?.should be_true
		end
		
		it "all pages except the rootpage must have a parent_id" do
			page = Factory.build(:page, :page_layout => "anypage", :parent_id => nil, :language => @language)
			page.valid?
			page.errors.should have_key(:parent_id)
		end
		
		it "must not be created if the page_layout is set to 'rootpage' and a page already exists with this page_layout and parent_id = nil" do
		  page = Factory.build(:page, :name => "anypage", :page_layout => "rootpage", :parent_id => @language_root.id, :language => @language)
			page.valid?
			page.errors.should have_key(:page_layout)	
		end
	end
	
	it "should get a webfriendly urlname on create" do
		page = Factory(:page, :name => 'klingon$&stößel ', :language => @language, :parent_id => @language_root.id)
		page.urlname.should == 'klingon-stoessel'
	end
	
  it "should generate a three letter urlname from two letter name" do
    page = Factory(:page, :name => 'Au', :language => @language, :parent_id => @language_root.id)
    page.urlname.should == '-au'
  end
  
  it "should generate a three letter urlname from two letter name with umlaut" do
    page = Factory(:page, :name => 'Aü', :language => @language, :parent_id => @language_root.id)
    page.urlname.should == 'aue'
  end
  
  it "should generate a three letter urlname from one letter name" do
    page = Factory(:page, :name => 'A', :language => @language, :parent_id => @language_root.id)
    page.urlname.should == '--a'
  end
  
	context "Root pages" do
		it "should contain one ore more rootpages" do
			Page.where(:parent_id => nil).any?
		end
	end
	
	context "with children" do
		before(:each) do
			@first_child = Factory(:page, :name => "First child", :language => @language, :public => false, :parent_id => @language_root.id)
			@first_child.move_to_child_of(@language_root)
			
			@first_public_child = Factory(:page, :name => "First public child", :language => @language, :parent_id => @language_root.id, :public => true)
			@first_public_child.move_to_child_of(@language_root)
		end
		
		it "should return a page object (or nil if no public children exists) for first_public_child" do
			if @language_root.children.any?
				@language_root.first_public_child.should == @first_public_child
			else
				@language_root.first_public_child.should == nil
			end
		end
	end
	
end