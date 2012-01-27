require 'spec_helper'

include Alchemy::BaseHelper

describe Alchemy::PagesHelper do

	before(:each) do
		helper.stub(:configuration).and_return(false)
	end

	it "should render the current page layout" do
		@page = Factory(:public_page)
		render_page_layout.should have_selector('div#content')
	end

	describe "#render_navigation" do

		before(:each) do
			@language = Alchemy::Language.get_default
			@root_page = Factory(:language_root_page, :language => @language, :name => 'Home')
			@page = Factory(:public_page, :language => @language, :parent_id => @root_page.id, :visible => true)
		end

		context "not in multi_language mode" do

			before(:each) do
				helper.stub(:multi_language?).and_return(false)
			end

			it "should render the page navigation" do
				helper.render_navigation.should have_selector('ul.navigation_level_1 li.a-public-page.active.last a.active[href="/alchemy/a-public-page"]')
			end

			context "with enabled url nesting" do

				before(:each) do
					helper.stub!(:configuration).and_return(true)
					@level2 = Factory(:public_page, :parent_id => @page.id, :language => @language, :name => 'Level 2', :visible => true)
					@page = Factory(:public_page, :parent_id => @level2.id, :language => @language, :name => 'Nested Page', :visible => true)
				end

				it "should render nested page links" do
					helper.render_navigation(:all_sub_menues => true).should have_selector('ul li a[href="/alchemy/a-public-page/level-2/nested-page"]')
				end

			end

		end

	end

	describe '#render_subnavigation' do

		before(:each) do
			@language = Alchemy::Language.get_default
			@language_root = Factory(:language_root_page, :language => @language, :name => 'Intro')
			@level_1 = Factory(:public_page, :language => @language, :parent_id => @language_root.id, :visible => true, :name => 'Level 1')
			@level_2 = Factory(:public_page, :language => @language, :parent_id => @level_1.id, :visible => true, :name => 'Level 2')
			@level_3 = Factory(:public_page, :language => @language, :parent_id => @level_2.id, :visible => true, :name => 'Level 3')
			@level_4 = Factory(:public_page, :language => @language, :parent_id => @level_3.id, :visible => true, :name => 'Level 4')
			helper.stub(:multi_language?).and_return(false)
		end

		it "should return nil if no @page is set" do
			helper.render_subnavigation.should be(nil)
		end

		context "showing a page with level 2" do

			before(:each) do
				@page = @level_2
			end

			it "should render the navigation from current page" do
				helper.render_subnavigation.should have_selector('ul > li > a[href="/alchemy/level-2"]')
			end

			it "should set current page active" do
				helper.render_subnavigation.should have_selector('a[href="/alchemy/level-2"].active')
			end

		end

		context "showing a page with level 3" do

			before(:each) do
				@page = @level_3
			end

			it "should render the navigation from current pages parent" do
				helper.render_subnavigation.should have_selector('ul > li > ul > li > a[href="/alchemy/level-3"]')
			end

			it "should set current page active" do
				helper.render_subnavigation.should have_selector('a[href="/alchemy/level-3"].active')
			end

		end

		context "showing a page with level 4" do

			before(:each) do
				@page = @level_4
			end

			it "should render the navigation from current pages parents parent" do
				helper.render_subnavigation.should have_selector('ul > li > ul > li > ul > li > a[href="/alchemy/level-4"]')
			end

			it "should set current page active" do
				helper.render_subnavigation.should have_selector('a[href="/alchemy/level-4"].active')
			end
			
			context "beginning with level 3" do

				it "should render the navigation beginning from its parent" do
					helper.render_subnavigation(:level => 3).should have_selector('ul > li > ul > li > a[href="/alchemy/level-4"]')
				end

			end

		end

	end

	describe "#render_breadcrumb" do
		
		before(:each) do
			helper.stub(:multi_language?).and_return(false)
			@root = mock_model('Page', :urlname => 'root', :name => 'Root', :title => 'Root', :visible? => false, :public? => false, :restricted? => false)
			@language_root = mock_model('Page', :urlname => 'language_root', :name => 'Language Root', :title => 'Language Root', :visible? => true, :public? => true, :restricted? => false)
			@page = mock_model('Page', :urlname => 'a-public-page', :name => 'A Public Page', :title => 'A Public Page', :visible? => true, :public? => true, :restricted? => false)
			@root.should_receive(:parent).and_return(nil)
			@language_root.should_receive(:parent).and_return(@root)
			@page.should_receive(:parent).and_return(@language_root)
		end
		
		it "should render a breadcrumb to current page" do
			helper.render_breadcrumb.should have_selector('a.active.last[href="/alchemy/a-public-page"]')
		end

		it "should render a breadcrumb with a alternative seperator" do
			helper.render_breadcrumb(:seperator => '<span>###</span>').should have_selector('span[contains("###")]')
		end

		it "should render a breadcrumb in reversed order" do
			helper.render_breadcrumb(:reverse => true).should have_selector('a.active.first[href="/alchemy/a-public-page"]')
		end

		it "should render a breadcrumb of restricted pages only" do
			@page.stub!(:restricted? => true, :urlname => 'a-restricted-public-page', :name => 'A restricted Public Page', :title => 'A restricted Public Page')
			helper.render_breadcrumb(:restricted_only => true).should match(/^(<a(.[^>]+)>)A restricted Public Page/)
		end

		it "should render a breadcrumb of visible pages only" do
			@page.stub!(:visible? => false, :urlname => 'a-invisible-public-page', :name => 'A invisible Public Page', :title => 'A invisible Public Page')
			helper.render_breadcrumb(:visible_only => true).should_not match(/A invisible Public Page/)
		end

		it "should render a breadcrumb of visible and invisible pages" do
			@page.stub!(:visible? => false, :urlname => 'a-invisible-public-page', :name => 'A invisible Public Page', :title => 'A invisible Public Page')
			helper.render_breadcrumb(:visible_only => false).should match(/A invisible Public Page/)
		end
		
		it "should render a breadcrumb of published pages only" do
			@page.stub!(:public => false, :public? => false, :urlname => 'a-unpublic-page', :name => 'A Unpublic Page', :title => 'A Unpublic Page')
			helper.render_breadcrumb(:public_only => true).should_not match(/A Unpublic Page/)
		end
		
		it "should render a breadcrumb of published and unpublished pages" do
			@page.stub!(:public => false, :public? => false, :urlname => 'a-unpublic-page', :name => 'A Unpublic Page', :title => 'A Unpublic Page')
			helper.render_breadcrumb(:public_only => false).should match(/A Unpublic Page/)
		end

		it "should render a breadcrumb without the page named 'Not Me'" do
			@page.stub!(:urlname => 'not-me', :name => 'Not Me', :title => 'Not Me')
			helper.render_breadcrumb(:without => @page).should_not match(/Not Me/)
		end
		
	end

	describe "using own url helpers" do

		before(:each) do
			@page = mock_model(Alchemy::Page, :urlname => 'testpage', :language_code => 'en')
		end

		describe "#show_page_path_params" do

			context "when multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(true)
				end

				it "should return a Hash with urlname and language_id parameter" do
					helper.stub!(:multi_language?).and_return(true)
					helper.show_page_path_params(@page).should include(:urlname => 'testpage', :lang => 'en')
				end

				it "should return a Hash with urlname, language_id and query parameter" do
					helper.stub!(:multi_language?).and_return(true)
					helper.show_page_path_params(@page, {:query => 'test'}).should include(:urlname => 'testpage', :lang => 'en', :query => 'test')
				end

			end

			context "not multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(false)
				end

				it "should return a Hash with the urlname but without language_id parameter" do
					helper.show_page_path_params(@page).should include(:urlname => 'testpage')
					helper.show_page_path_params(@page).should_not include(:lang => 'en')
				end

				it "should return a Hash with urlname and query parameter" do
					helper.show_page_path_params(@page, {:query => 'test'}).should include(:urlname => 'testpage', :query => 'test')
					helper.show_page_path_params(@page).should_not include(:lang => 'en')
				end

			end

		end

		describe "#show_alchemy_page_path" do

			context "when multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(true)
				end

				it "should return the correct relative path string" do
					helper.show_alchemy_page_path(@page).should == "/alchemy/#{@page.language_code}/testpage"
				end

				it "should return the correct relative path string with additional parameters" do
					helper.show_alchemy_page_path(@page, {:query => 'test'}).should == "/alchemy/#{@page.language_code}/testpage?query=test"
				end

			end

			context "not multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(false)
				end

				it "should return the correct relative path string" do
					helper.show_alchemy_page_path(@page).should == "/alchemy/testpage"
				end

				it "should return the correct relative path string with additional parameter" do
					helper.show_alchemy_page_path(@page, {:query => 'test'}).should == "/alchemy/testpage?query=test"
				end

			end

		end

		describe "#show_alchemy_page_url" do

			context "when multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(true)
				end

				it "should return the correct url string" do
					helper.show_alchemy_page_url(@page).should == "http://#{helper.request.host}/alchemy/#{@page.language_code}/testpage"
				end

				it "should return the correct url string with additional parameters" do
					helper.show_alchemy_page_url(@page, {:query => 'test'}).should == "http://#{helper.request.host}/alchemy/#{@page.language_code}/testpage?query=test"
				end

			end

			context "not multi_language" do

				before(:each) do
					helper.stub!(:multi_language?).and_return(false)
				end

				it "should return the correct url string" do
					helper.show_alchemy_page_url(@page).should == "http://#{helper.request.host}/alchemy/testpage"
				end

				it "should return the correct url string with additional parameter" do
					helper.show_alchemy_page_url(@page, {:query => 'test'}).should == "http://#{helper.request.host}/alchemy/testpage?query=test"
				end

			end
		end
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
			helper.render_title_tag(:prefix => 'Peters Petshop', :seperator => ' ### ').should have_selector('title[contains("Peters Petshop ### A Public Page")]')
		end
	end

  describe "#language_switcher" do

		before :each do
			@default_language = Alchemy::Language.get_default
			@klingonian = Factory(:language)
			# simulates link_to_public_child = true
			helper.stub(:multi_language?).and_return(true)
			helper.stub(:configuration) { |arg| arg == :redirect_to_public_child ? true : false }
		end

		it "should return nil when having only one public language" do
			helper.language_switcher.should be nil
		end

		context "with two public languages and two language_roots" do

			before :each do
				@default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Default Language Root')
				@klingonian_language_root = Factory(:language_root_page)
			end

			context "and config redirect_to_public_child is set to TRUE" do

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
