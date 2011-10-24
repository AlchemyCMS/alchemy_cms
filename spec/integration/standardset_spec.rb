require 'spec_helper'

describe 'Alchemy Standard Set' do

	before(:each) do
		# We need an user or the signup view will show up
	  Factory(:admin_user)
		@language = Language.get_default
		@language_root = Factory(:language_root_page, :language => @language, :name => 'Home')
	end

	it "should render a whole page including all its elements and contents" do
		p = Factory(:public_page, :language => @language)
		article = p.elements.find_by_name('article')
		article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
		visit '/a-public-page'
		within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
	end

	it "should render the navigation with all visible pages" do
		pages = [
			Factory(:public_page, :language => @language, :visible => true, :name => 'Page 1', :parent_id => @language_root.id),
			Factory(:public_page, :language => @language, :visible => true, :name => 'Page 2', :parent_id => @language_root.id)
		]
		visit '/'
		within('div#navigation ul') { page.should have_selector('li a[href="/page-1"], li a[href="/page-2"]') }
	end

	context "fulltext search" do
	
		before(:each) do
		  @page = Factory(:public_page, :language => @language, :visible => true, :name => 'Page 1', :parent_id => @language_root.id)
			@element = Factory(:element, :name => 'article', :page => @page)
		end
	
	  it "should display search results for richtext essences" do
			@element.content_by_name('text').essence.update_attributes(:body => '<p>Welcome to Peters Petshop</p>', :public => true)
			search_result_page = Factory(:public_page, :language => @language, :name => 'Suche', :page_layout => 'search', :parent_id => @language_root.id)
			visit('/suche?query=Petshop')
			within('div#content .searchresult') { page.should have_content('Petshop') }
	  end
	
	  it "should display search results for text essences" do
			@element.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
			search_result_page = Factory(:public_page, :language => @language, :name => 'Suche', :page_layout => 'search', :parent_id => @language_root.id)
			visit('/suche?query=Petshop')
			within('div#content .searchresult') { page.should have_content('Petshop') }
	  end
	
	end

end
