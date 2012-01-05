require 'spec_helper'

describe Alchemy::PagesController do
	
	before(:each) do
		@default_language = Alchemy::Language.get_default
		@default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Home')
	end

	describe "#show" do

		it "should include all its elements and contents" do
			p = Factory(:public_page, :language => @default_language)
			article = p.elements.find_by_name('article')
			article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
			visit '/alchemy/a-public-page'
			within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
		end

		it "should show the navigation with all visible pages" do
			pages = [
				Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id),
				Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 2', :parent_id => @default_language_root.id)
			]
			visit '/alchemy/'
			within('div#navigation ul') { page.should have_selector('li a[href="/alchemy/page-1"], li a[href="/alchemy/page-2"]') }
		end

	end

	describe "fulltext search" do

		before(:each) do
			@page = Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id)
			@element = Factory(:element, :name => 'article', :page => @page)
			Factory(:public_page, :language => @default_language, :name => 'Suche', :page_layout => 'search', :parent_id => @default_language_root.id)
		end

		it "should have a correct path in the form tag" do
			visit('/alchemy/suche')
			page.should have_selector('div#content form[action="/alchemy/suche"]')
		end

		context "performing the search" do

			it "should display search results for richtext essences" do
				@element.content_by_name('text').essence.update_attributes(:body => '<p>Welcome to Peters Petshop</p>', :public => true)
				visit('/alchemy/suche?query=Petshop')
				within('div#content .search_result') { page.should have_content('Petshop') }
			end

			it "should display search results for text essences" do
				@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
				visit('/alchemy/suche?query=Petshop')
				within('div#content .search_result') { page.should have_content('Petshop') }
			end

			it "should not find contents placed on global-pages (layoutpage => true)" do
				@page.update_attributes(:layoutpage => true)
				@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
				visit('/alchemy/suche?query=Petshop')
				within('div#content') { page.should have_css('h2.no_search_results') }
			end

			it "should not find contents placed on unpublished pages (public => false)" do
				@page.update_attributes(:public => false)
				@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
				visit('/alchemy/suche?query=Petshop')
				within('div#content') { page.should have_css('h2.no_search_results') }
			end

			it "should not find contents placed on restricted pages (restricted => true)" do
				@page.update_attributes(:restricted => true)
				@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
				visit('/alchemy/suche?query=Petshop')
				within('div#content') { page.should have_css('h2.no_search_results') }
			end

		end

	end

	describe "redirecting" do

		context "in multi language mode", :focus => true do

			before(:each) do
				@page = Factory(:public_page)
				Alchemy::Config.stub!(:get) { |arg| arg == :url_nesting ? true : Alchemy::Config.parameter(arg) }
			end

			it "should redirect to url with nested language code" do
				visit '/alchemy/a-public-page'
				page.current_path.should == '/alchemy/de/a-public-page'
			end

			context "should redirect to public child" do

				before(:each) do
					@page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
					@child = Factory(:public_page, :name => 'Public Child', :parent_id => @page.id)
					Alchemy::Config.stub!(:get) { |arg| arg == :url_nesting ? false : Alchemy::Config.parameter(arg) }
				end

				it "if requested page is unpublished" do
					visit '/alchemy/kl/not-public'
					page.current_path.should == '/alchemy/kl/public-child'
				end

				it "with nested language code, if requested page is unpublished and url has no language code" do
					visit '/alchemy/not-public'
					page.current_path.should == '/alchemy/kl/public-child'
				end

			end

			it "should redirect to pages url, if requested url is index url" do
				visit '/alchemy/'
				page.current_path.should == '/alchemy/de/home'
			end

			it "should redirect to pages url, if requested url is only the language code" do
				visit '/alchemy/de'
				page.current_path.should == '/alchemy/de/home'
			end

			it "should keep additional params" do
				visit '/alchemy/a-public-page?query=Peter'
				page.current_url.should match(/\?query=Peter/)
			end

			context "url nesting" do

				before(:each) do
					@level1 = Factory(:public_page, :parent_id => @default_language_root.id, :name => 'catalog', :language => @default_language)
					@level2 = Factory(:public_page, :parent_id => @level1.id, :name => 'products', :language => @default_language)
					@level3 = Factory(:public_page, :parent_id => @level2.id, :name => 'screwdriver', :language => @default_language)
				end

				context "enabled" do

					before(:each) do
						Alchemy::Config.stub!(:get) { |arg| arg == :url_nesting ? true : Alchemy::Config.parameter(arg) }
					end

					context "requesting a non nested url" do

						it "should redirect to nested url" do
							visit "/alchemy/de/screwdriver"
							page.current_path.should == '/alchemy/de/catalog/products/screwdriver'
						end

						it "should only redirect to nested url if page is nested" do
							visit "/alchemy/de/catalog"
							page.status_code.should == 200
							page.current_path.should == "/alchemy/de/catalog"
						end

					end

				end

				context "disabled" do

					before(:each) do
						Alchemy::Config.stub!(:get) { |arg| arg == :url_nesting ? false : Alchemy::Config.parameter(arg) }
					end

					context "requesting a nested url" do

						it "should redirect to not nested url" do
							visit "/alchemy/de/catalog/products/screwdriver"
							page.current_path.should == "/alchemy/de/screwdriver"
						end

					end

				end

			end

		end

		context "not in multi language mode" do

			before(:each) do
				@page = Factory(:public_page, :language => @default_language, :parent_id => @default_language_root.id)
				Alchemy::Config.stub!(:get) { |arg| arg == :url_nesting ? false : Alchemy::Config.parameter(arg) }
			end

			it "should redirect from nested language code url to normal url" do
				visit '/alchemy/de/a-public-page'
				page.current_path.should == '/alchemy/a-public-page'
			end

			context "with no lang parameter" do

				it "should have defaults language language_id in the session" do
					get show_page_path(:urlname => 'a-public-page')
					controller.session[:language_id].should == Alchemy::Language.get_default.id
				end

				it "should have defaults language language_code in the session" do
					get show_page_path(:urlname => 'a-public-page')
					controller.session[:language_code].should == Alchemy::Language.get_default.code
				end

			end

			context "should redirect to public child" do

				before(:each) do
					@page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
					@child = Factory(:public_page, :name => 'Public Child', :parent_id => @page.id, :language => @default_language)
				end

				it "if requested page is unpublished" do
					visit '/alchemy/not-public'
					page.current_path.should == '/alchemy/public-child'
				end

				it "with normal url, if requested url has nested language code and is not public" do
					visit '/alchemy/de/not-public'
					page.current_path.should == '/alchemy/public-child'
				end

			end

			it "should redirect to pages url, if requested url is index url" do
				visit '/alchemy/'
				page.current_path.should == '/alchemy/home'
			end

			it "should keep additional params" do
				visit '/alchemy/de/a-public-page?query=Peter'
				page.current_url.should match(/\?query=Peter/)
			end

		end

	end

end
