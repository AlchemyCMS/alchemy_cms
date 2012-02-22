# encoding: UTF-8

require 'spec_helper'

describe Alchemy::Page do
	
	before(:each) do
		@rootpage = Alchemy::Page.root
		@language = Alchemy::Language.get_default
		@language_root = Factory(:language_root_page, :name => 'Default Language Root', :language => @language)
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
		Alchemy::Page.rootpage.should be_instance_of(Alchemy::Page)
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

	describe '#create' do

		context "before/after filter" do

			it "should automatically set the title from its name" do
				page = Factory(:page, :name => 'My Testpage', :language => @language, :parent_id => @language_root.id)
				page.title.should == 'My Testpage'
			end

			it "should get a webfriendly urlname" do
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

	end

	describe '#update' do

		context "before/after filter" do

			it "should not set the title automatically if the name changed but title is not blank" do
				page = Factory(:page, :name => 'My Testpage', :language => @language, :parent_id => @language_root.id)
				page.name = "My Renaming Test"
				page.save; page.reload
				page.title.should == "My Testpage"
			end

			it "should not automatically set the title if it changed its value" do
				page = Factory(:page, :name => 'My Testpage', :language => @language, :parent_id => @language_root.id)
				page.title = "I like SEO"
				page.save; page.reload
				page.title.should == "I like SEO"
			end

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

		it "should return pages that are public" do
			Factory(:public_page, :name => 'First Public Child', :parent_id => @language_root.id, :language => @language)
			Factory(:public_page, :name => 'Second Public Child', :parent_id => @language_root.id, :language => @language)
			Alchemy::Page.published.should have(3).pages
		end

	end

	context ".not_locked" do

		it "should return pages that are not blocked by a user at the moment" do
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

	describe '.all_from_clipboard_for_select' do

		context "with clipboard holding pages having non unique page layout" do

			it "should return the pages" do
				page_1 = Factory(:page, :language => @language)
				page_2 = Factory(:page, :language => @language)
				clipboard = [
					{:id => page_1.id, :action => "copy"},
					{:id => page_2.id, :action => "copy"}
				]
				Alchemy::Page.all_from_clipboard_for_select(clipboard, @language.id).should == [page_1, page_2]
			end

		end

		context "with clipboard holding a page having unique page layout" do

			it "should not return any pages" do
				page_1 = Factory(:page, :language => @language, :page_layout => 'contact')
				clipboard = [
					{:id => page_1.id, :action => "copy"}
				]
				Alchemy::Page.all_from_clipboard_for_select(clipboard, @language.id).should == []
			end

		end

		context "with clipboard holding two pages. One having a unique page layout." do

			it "should return one page" do
				page_1 = Factory(:page, :language => @language, :page_layout => 'standard')
				page_2 = Factory(:page, :language => @language, :page_layout => 'contact')
				clipboard = [
					{:id => page_1.id, :action => "copy"},
					{:id => page_2.id, :action => "copy"}
				]
				Alchemy::Page.all_from_clipboard_for_select(clipboard, @language.id).should == [page_1]
			end

		end

	end

	describe "validations" do

		context "creating a normal content page" do

			before(:each) do
				@contentpage = Factory.build(:page, :parent_id => nil, :page_layout => nil)
			end

			it "should validate the page_layout" do
				@contentpage.save
				@contentpage.should have(1).error_on(:page_layout)
			end

			it "should validate the parent_id" do
				@contentpage.save
				@contentpage.should have(1).error_on(:parent_id)
			end

		end

		context "creating the rootpage without parent_id and page_layout" do

			before(:each) do
				Alchemy::Page.delete_all
				@rootpage = Factory.build(:page, :parent_id => nil, :page_layout => nil, :name => 'Rootpage')
			end

			it "should be valid" do
				@rootpage.save
				@rootpage.should be_valid
			end

		end

		context "saving a systempage" do

			before(:each) do
				@systempage = Factory.build(:systempage)
			end

			it "should not validate the page_layout" do
				@systempage.save
				@systempage.should be_valid
			end

		end

	end

	describe 'before and after filters' do

		context "a normal page" do

			before(:each) do
				@page = Factory.build(:page, :language_code => nil, :language => Factory(:language))
			end

			it "should get the language code for language" do
				@page.save
				@page.language_code.should == "kl"
			end

			it "should autogenerate the elements" do
				@page.save
				@page.elements.should_not be_empty
			end

			context "with children getting restricted set to true" do

				before(:each) do
					@page.save
					@child1 = Factory(:page, :name => 'Child 1', :parent_id => @page.id)
					@page.reload
					@page.restricted = true
					@page.save
				end

				it "should restrict all its children" do
					@child1.reload
					@child1.restricted?.should be_true
				end

			end

			context "with restricted parent gets created" do

				before(:each) do
					@page.save
					@page.parent.update_attributes(:restricted => true)
					@new_page = Factory(:page, :name => 'New Page', :parent_id => @page.id)
				end

				it "should also be restricted" do
					@new_page.restricted?.should be_true
				end

			end

			context "with do_not_autogenerate set to true" do

				before(:each) do
					@page.do_not_autogenerate = true
				end

				it "should not autogenerate the elements" do
					@page.save
					@page.elements.should be_empty
				end

			end

		end

		context "a systempage" do

			before(:each) do
				@page = Factory(:systempage)
			end

			it "should not get the language code for language" do
				@page.language_code.should be_nil
			end

			it "should not autogenerate the elements" do
				@page.elements.should be_empty
			end

		end

	end

end
