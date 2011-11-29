require 'spec_helper'

include Alchemy::BaseHelper

describe Alchemy::PagesHelper do
	
	it "should render the current page layout" do
		@page = Factory(:public_page)
		helper.stub(:configuration).and_return(true)
		render_page_layout.should have_selector('div#content')
	end

	describe "#render_navigation" do
		it "should render the page navigation" do
			@language = Alchemy::Language.get_default
			@root_page = Factory(:language_root_page, :language => @language, :name => 'Home')
			@page = Factory(:public_page, :language => @language, :parent_id => @root_page.id, :visible => true)
			helper.stub(:multi_language?).and_return(false)
			helper.render_navigation.should have_selector('ul.navigation_level_1 li.a-public-page.active.last a.active[href="/alchemy/a-public-page"]')
		end
	end
	
	describe "#render_breadcrumb" do
		it "should render a breadcrumb to current page" do
			helper.stub(:multi_language?).and_return(false)
			@language_root = mock_model('Page', :urlname => 'language_root', :name => 'Language Root', :title => 'Language Root', :visible? => true, :public? => true, :restricted? => false)
			@page = mock_model('Page', :urlname => 'a-public-page', :name => 'A Public Page', :title => 'A Public Page', :visible? => true, :public? => true, :restricted? => false)
			@language_root.should_receive(:parent).and_return(nil)
			@page.should_receive(:parent).and_return(@language_root)
			helper.render_breadcrumb.should have_selector('a.active.last[href="/alchemy/a-public-page"]')
		end
		
		it "should render a breadcrumb with a alternative seperator"
		it "should render a breadcrumb in reversed order"
		it "should render a breadcrumb of restricted pages only"
		it "should render a breadcrumb of unvisible pages only"
		it "should render a breadcrumb of published pages only"
		it "should render a breadcrumb without the page named 'Not Me'"
	end
	
	describe "#render_meta_data" do
		
		let(:language) do
			mock_model('Language', :code => 'en')
		end
		
		it "should render meta keywords of current page" do
			@page = mock_model('Page', :language => language, :title => 'A Public Page', :meta_description => '', :meta_keywords => 'keyword1, keyword2', :robot_index? => false, :robot_follow? => false, :contains_feed? => false, :updated_at => '2011-11-29-23:00:00')
			helper.render_meta_data.should have_selector('meta[name="keywords"][content="keyword1, keyword2"]')
		end
		
		it "should render meta description 'blah blah' of current page" do
			@page = mock_model('Page', :language => language, :title => 'A Public Page', :meta_description => 'blah blah', :meta_keywords => '', :robot_index? => false, :robot_follow? => false, :contains_feed? => false, :updated_at => '2011-11-29-23:00:00')
			helper.render_meta_data.should have_selector('meta[name="description"][content="blah blah"]')
		end
	end

	describe "#render_title_tag" do
		it "should render a title tag for current page" do
			@page = mock_model('Page', :title => 'A Public Page')
			helper.render_title_tag.should have_selector('title[contains("A Public Page")]')
		end
		
		it "should render a title tag for current page with a prefix and a seperator" do
			@page = mock_model('Page', :title => 'A Public Page')
			helper.render_title_tag(:prefix => 'Peters Petshop', :seperator => '###').should have_selector('title[contains("Peters Petshop ### A Public Page")]')
		end
	end

  describe "#language_switcher" do

		before :each do
			@default_language = Alchemy::Language.get_default
			@klingonian = Factory(:language)
			# simulates link_to_public_child = true
			helper.stub(:configuration).and_return(true)
			helper.stub(:multi_language?).and_return(true)
		end

		it "should return nil when having only one public language" do
			helper.stub(:configuration).and_return(true)
			helper.language_switcher.should be nil
		end

		context "with two public languages and two language_roots" do

			before :each do
				@default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Default Language Root')
				@klingonian_language_root = Factory(:language_root_page)
			end
			
			context "and config redirect_to_public_child is set to TRUE" do
				
				before :each do
					# simulates link_to_public_child = true
					helper.stub(:configuration).and_return(true)
				end
				
				it "should return nil if only one language_root is public and both do not have children" do
					@klingonian_language_root.update_attributes(:public => false)
					helper.language_switcher.should == nil
				end
				
				it "should return nil if only one language_root is public and both have none public children" do
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => false, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => false, :name => "child1")
					helper.language_switcher.should == nil
				end
				
				it "should render two links when having two public language_root pages" do
					helper.language_switcher.should have_selector('a', :count => 2)
				end
			
				it "should render two links when having just one public language_root but a public children in both language_roots" do
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => true, :name => "child1")
					helper.language_switcher.should have_selector('a', :count => 2)
				end
			
				it "should render two links when having two not public language_roots but a public children in both" do
					@default_language_root.update_attributes(:public => false)
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => true, :name => "child1")
					helper.language_switcher.should have_selector('a', :count => 2)
				end
			
				it "should return nil when having two not public language_roots and a public children in only one of them" do
					@default_language_root.update_attributes(:public => false)
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => false, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => true, :name => "child1")
					helper.language_switcher.should == nil
				end
				
			end
		
			context "and config redirect_to_public_child is set to FALSE" do
				
				before :each do
					# simulates link_to_public_child = false
					helper.stub(:configuration).and_return(false)
				end
				
				it "should render two links when having two public language_root pages" do
					helper.language_switcher.should have_selector('a', :count => 2)
				end
				
				it "should render nil when having just one public language_root but a public children in both language_roots" do
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => true, :name => "child1")
					helper.language_switcher.should == nil
				end
				
				it "should render nil when having two not public language_roots but a public children in both" do
					@default_language_root.update_attributes(:public => false)
					@klingonian_language_root.update_attributes(:public => false)
					@default_first_public_child = Factory(:page, :language => @default_language, :parent_id => @default_language_root.id, :public => true, :name => "child1")
					@klingonian_first_public_child = Factory(:page, :language => @klingonian, :parent_id => @klingonian_language_root.id, :public => true, :name => "child1")
					helper.language_switcher.should == nil
				end
				
			end
		
		end
		
	end

end
