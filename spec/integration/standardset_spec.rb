require 'spec_helper'

describe 'Alchemy Standard Set' do

	before(:each) do
		# We need an user or the signup view will show up
	  Factory(:admin_user)
	end

	it "should render a whole page including all its elements and contents" do
		p = Factory(:public_page, :language => Language.get_default)
		article = p.elements.find_by_name('article')
		article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
		visit '/de/a-public-page'
		within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
	end

	it "should render the navigation with all visible pages" do
		language = Language.get_default
		language_root = Factory(:language_root_page, :language => language, :name => 'Home')
		pages = [
			Factory(:public_page, :language => language, :visible => true, :name => 'Page 1', :parent_id => language_root.id),
			Factory(:public_page, :language => language, :visible => true, :name => 'Page 2', :parent_id => language_root.id)
		]
		visit '/'
		within('div#navigation ul') { page.should have_selector('li a[href="/page-1"], li a[href="/page-2"]') }
	end

end
