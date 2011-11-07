require 'spec_helper'

describe PagesController do

	before(:each) do
		# We need an user or the signup view will show up
	  user = Factory.build(:admin_user)
    user.save_without_session_maintenance
		@default_language = Language.get_default
		@default_language_root = Factory(:language_root_page, :language => @default_language, :name => 'Home')
	end

	context "rendering a page" do

		it "should including all its elements and contents" do
			p = Factory(:public_page, :language => @default_language)
			article = p.elements.find_by_name('article')
			article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
			visit '/a-public-page'
			within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
		end

		it "should have show the navigation with all visible pages" do
			pages = [
				Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id),
				Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 2', :parent_id => @default_language_root.id)
			]
			visit '/'
			within('div#navigation ul') { page.should have_selector('li a[href="/page-1"], li a[href="/page-2"]') }
		end
	  
	end

	context "performing a fulltext search" do
	
		before(:each) do
		  @page = Factory(:public_page, :language => @default_language, :visible => true, :name => 'Page 1', :parent_id => @default_language_root.id)
			@element = Factory(:element, :name => 'article', :page => @page)
		end
	
	  it "should display search results for richtext essences" do
			@element.content_by_name('text').essence.update_attributes(:body => '<p>Welcome to Peters Petshop</p>', :public => true)
			search_result_page = Factory(:public_page, :language => @default_language, :name => 'Suche', :page_layout => 'search', :parent_id => @default_language_root.id)
			visit('/suche?query=Petshop')
			within('div#content .searchresult') { page.should have_content('Petshop') }
	  end
	
	  it "should display search results for text essences" do
			@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
			search_result_page = Factory(:public_page, :language => @default_language, :name => 'Suche', :page_layout => 'search', :parent_id => @default_language_root.id)
			visit('/suche?query=Petshop')
			within('div#content .searchresult') { page.should have_content('Petshop') }
	  end
	
	end

	context "redirecting" do
		
		context "in multi language mode" do

			before(:each) do
			  @page = Factory(:public_page)
			end

			it "should redirect to url with nested language code" do
	    	visit '/a-public-page'
				page.current_path.should == '/de/a-public-page'
			end

			context "should redirect to public child" do
				
				before(:each) do
					@page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
					@child = Factory(:public_page, :name => 'Public Child', :parent_id => @page.id)
				end
				
				it ", if requested page is unpublished" do
		    	visit '/kl/not-public'
					page.current_path.should == '/kl/public-child'
				end

				it "with nested language code, if requested page is unpublished and url has no language code" do
		    	visit '/not-public'
					page.current_path.should == '/kl/public-child'
				end
			  
			end

			it "should redirect to pages url, if requested url is index url" do
	    	visit '/'
				page.current_path.should == '/de/home'
			end

			it "should redirect to pages url, if requested url is only the language code" do
	    	visit '/de'
				page.current_path.should == '/de/home'
			end

			it "should keep additional params" do
	    	visit '/a-public-page?query=Peter'
				page.current_url.should match(/\?query=Peter/)
	  	end

		end
		
		context "not in multi language mode" do

			before(:each) do
			  @page = Factory(:public_page, :language => @default_language, :parent_id => @default_language_root.id)
			end

		  it "should redirect from nested language code url to normal url" do
	    	visit '/de/a-public-page'
				page.current_path.should == '/a-public-page'
			end

			context "should redirect to public child" do
				
				before(:each) do
					@page.update_attributes(:public => false, :name => 'Not Public', :urlname => '')
					@child = Factory(:public_page, :name => 'Public Child', :parent_id => @page.id, :language => @default_language)
				end
				
			  it ", if requested page is unpublished" do
		    	visit '/not-public'
					page.current_path.should == '/public-child'
				end

				it "with normal url, if requested url has nested language code and is not public" do
		    	visit '/de/not-public'
					page.current_path.should == '/public-child'
				end
				
			end

			it "should redirect to pages url, if requested url is index url" do
	    	visit '/'
				page.current_path.should == '/home'
			end

		  it "should keep additional params" do
		    visit '/de/a-public-page?query=Peter'
				page.current_url.should match(/\?query=Peter/)
		  end

		end
		
	end

end
