require 'spec_helper'

describe 'Alchemy Standard Set' do

  it "should show the sitename ingredient as page title prefix" do
		pending "because we should spec creation of Page and Language first"
		header_page = Factory(:public_page)
		sitename = Factory(:element, :name => 'sitename', :page => header_page)
		sitename.content_by_name('name').essence.update_attributes(:body => 'Peters Petshop')
    visit '/'
		within('head title') { page.should have_content('Peters Petshop') }
  end

	it "should render a whole page including all its elements and contents"

end
