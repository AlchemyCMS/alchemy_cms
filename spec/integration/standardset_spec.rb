require 'spec_helper'

describe 'Alchemy Standard Set' do

	before(:each) do
		# We need an user or the signup view will show up
	  Factory(:registered_user)
	end

  it "should show the sitename ingredient as page title prefix"

	it "should render a whole page including all its elements and contents" do
		p = Factory(:public_page, :language => Language.get_default)
		article = p.elements.find_by_name('article')
		article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop', :public => true)
		visit '/de/a-public-page'
		within('div#content div.article div.intro') { page.should have_content('Welcome to Peters Petshop') }
	end

end
