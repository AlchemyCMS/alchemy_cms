# encoding: UTF-8

require 'spec_helper'

describe Alchemy::Page do
	
	before(:each) do
		@rootpage = Alchemy::Page.rootpage
		@language = Alchemy::Language.get_default
		@language_root = Factory(:page, :parent_id => @rootpage.id, :language => @language, :language_root => true, :page_layout => 'intro')
	end
	
	describe ".layout_description" do
		
		context "for a language root page" do
			
			it "should return the page layout description as hash" do
				@language_root.layout_description['name'].should == 'intro'
			end
			
			it "should return an empty hash for root page" do
				@rootpage.layout_description.should == {}
			end
			
		end
		
		it "should raise Exception if the page_layout could not be found in the definition file" do
			@page = mock(:page, :page_layout => 'foo')
			expect { @page.layout_description }.to raise_error
		end
		
	end
	
	it "should contain one rootpage" do
		Alchemy::Page.rootpage.should be_instance_of(Page)
	end

	it "should return all rss feed elements" do
		@page = Factory(:public_page, :page_layout => 'news', :parent_id => @language_root.id, :language => @language)
		@page.feed_elements.should == Alchemy::Element.find_all_by_name('news')
	end
	
	context "finding elements" do
	
		before(:each) do
			@page = Factory(:public_page)
			@non_public_elements = [
				Factory(:element, :public => false, :page => @page),
				Factory(:element, :public => false, :page => @page)
			]
		end
		
	  it "should return the collection of elements if passed an array into options[:collection]" do
			options = {:collection => @page.elements}
			@page.find_elements(options).all.should == @page.elements.all
		end
		
		context "with show_non_public argument TRUE" do

			it "should return all elements from empty options" do
				@page.find_elements({}, true).all.should == @page.elements.all
			end

			it "should only return the elements passed as options[:only]" do
				@page.find_elements({:only => ['article']}, true).all.should == @page.elements.named('article').all
			end

			it "should not return the elements passed as options[:except]" do
			  @page.find_elements({:except => ['article']}, true).all.should == @page.elements - @page.elements.named('article').all
			end

		  it "should return elements offsetted" do
			  @page.find_elements({:offset => 2}, true).all.should == @page.elements.offset(2)
		  end

		  it "should return elements limitted in count" do
			  @page.find_elements({:count => 1}, true).all.should == @page.elements.limit(1)
		  end

		end
		
		context "with show_non_public argument FALSE" do

			it "should return all elements from empty arguments" do
			   @page.find_elements().all.should == @page.elements.published.all
			end

			it "should only return the public elements passed as options[:only]" do
			  @page.find_elements(:only => ['article']).all.should == @page.elements.published.named('article').all
			end

			it "should return all public elements except the ones passed as options[:except]" do
			  @page.find_elements(:except => ['article']).all.should == @page.elements.published.all - @page.elements.published.named('article').all
			end

		  it "should return elements offsetted" do
			  @page.find_elements({:offset => 2}).all.should == @page.elements.published.offset(2)
		  end

		  it "should return elements limitted in count" do
			  @page.find_elements({:count => 1}).all.should == @page.elements.published.limit(1)
		  end

		end
	
	end
	
	context "create" do
		it "the rootpage with page_layout rootpage does not need a parent_id" do
			@rootpage.rootpage?.should be_true
		end
		
		it "all pages except the rootpage must have a parent_id" do
			page = Alchemy::Factory.build(:page, :page_layout => "anypage", :parent_id => nil, :language => @language)
			page.valid?
			page.should have(1).error_on(:parent_id)
		end
		
		it "must not be created if the page_layout is set to 'rootpage' and a page already exists with this page_layout and parent_id = nil" do
		  page = Alchemy::Factory.build(:page, :name => "anypage", :page_layout => "rootpage", :parent_id => @language_root.id, :language => @language)
			page.valid?
			page.should have(1).error_on(:page_layout)
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
	end
	
	context "with children" do
		before(:each) do
			@first_child = Factory(:page, :name => "First child", :language => @language, :public => false, :parent_id => @language_root.id)
			@first_child.move_to_child_of(@language_root)
			
			@first_public_child = Factory(:page, :name => "First public child", :language => @language, :parent_id => @language_root.id, :public => true)
			@first_public_child.move_to_child_of(@language_root)
		end
		
		it "should return a page object (or nil if no public child exists) for first_public_child" do
			if @language_root.children.any?
				@language_root.first_public_child.should == @first_public_child
			else
				@language_root.first_public_child.should == nil
			end
		end
	end
	
	context ".public" do
	  it "should return 2 pages that are public" do
			Factory(:public_page, :name => 'First Public Child', :parent_id => @language_root.id, :language => @language)
			Factory(:public_page, :name => 'Second Public Child', :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.published.should have(2).pages
	  end
	end
		
	context ".not_locked" do
	  it "should return 3 pages that are not blocked by a user at the moment" do
	    Factory(:public_page, :locked => true, :name => 'First Public Child', :parent_id => @language_root.id, :language => @language)
			Factory(:public_page, :name => 'Second Public Child', :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.not_locked.should have(3).pages
	  end
	end
	context ".all_locked" do
	  it "should return 1 page that is blocked by a user at the moment" do
	    Factory(:public_page, :locked => true, :name => 'First Public Child', :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.all_locked.should have(1).pages
	  end
	end
	
	context ".language_roots" do
	  it "should return 1 language_root" do
			Factory(:public_page, :name => 'First Public Child', :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.language_roots.should have(1).pages
	  end
	end
	
	
	context ".layoutpages" do
	  it "should return 1 layoutpage" do
			Factory(:public_page, :layoutpage => true, :name => 'Layoutpage', :parent_id => @rootpage.id, :language => @language)
	    Alchemy::Page.layoutpages.should have(1).pages
	  end
	end
	
	context ".visible" do
	  it "should return 1 visible page" do
	    Factory(:public_page, :name => 'First Public Child', :visible => true, :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.visible.should have(1).pages
	  end
	end
	
	context ".accessable" do
	  it "should return 2 accessable pages" do
	    Factory(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => @language_root.id, :language => @language)
			Alchemy::Page.accessable.should have(2).pages
	  end
	end
	
	context ".restricted" do
	  it "should return 1 restricted page" do
	    Factory(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => @language_root.id, :language => @language)
	    Alchemy::Page.restricted.should have(1).pages
	  end
	end
	
	describe "#cell_definitions" do

		before(:each) do
			@page = Factory.build(:page, :page_layout => 'foo')
			@page.stub!(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"]})
			@cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
			Alchemy::Cell.stub!(:definitions).and_return(@cell_descriptions)
		end

		it "should return all cell definitions for its page_layout" do
			@page.cell_definitions.should == @cell_descriptions
		end

		it "should return empty array if no cells defined in page layout" do
			@page.stub!(:layout_description).and_return({'name' => "foo"})
			@page.cell_definitions.should == []
		end

	end

	describe "#elements_grouped_by_cells" do

		context "with no elements defined that are not defined in a cell" do
			it "should not have a cell for 'other elements'" do
				@page = Factory.build(:page, :page_layout => 'foo')
				@page.stub!(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"], 'elements' => ["1", "2"]})
				@cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
				Alchemy::Cell.stub!(:definitions).and_return(@cell_descriptions)
				@page.elements_grouped_by_cells.keys.collect(&:name).should_not include('for_other_elements')
			end
		end

		context "with elements defined that are not defined in a cell" do
			it "should have a cell for 'other elements'" do
				@page = Factory.build(:page, :page_layout => 'foo')
				@page.stub!(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"], 'elements' => ["1", "2", "3"]})
				@cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
				Alchemy::Cell.stub!(:definitions).and_return(@cell_descriptions)
				@page.elements_grouped_by_cells.keys.collect(&:name).should include('for_other_elements')
			end
		end

	end

end