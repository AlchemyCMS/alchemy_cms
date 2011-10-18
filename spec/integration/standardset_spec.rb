require 'spec_helper'

describe 'Alchemy Standard Set' do

	before(:each) do
		# We need an user or the signup view will show up
	  Factory(:registered_user)
	end

  it "should show the sitename ingredient as page title prefix"

	it "should render a whole page including all its elements and contents" do
		page = Factory(:public_page)
		article = Factory(:element, :name => 'article', :page => page)
		article.content_by_name('intro').essence.update_attributes(:body => 'Welcome to Peters Petshop')
    visit '/a-public-page'
		within('#content') { page.should have_content('Welcome to Peters Petshop') }
	end

end
