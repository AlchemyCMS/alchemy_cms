require 'spec_helper'

describe 'Alchemy Standard Set' do

  it "should show the sitename ingredient as page title prefix" do
		pending "because rails 3 has other yaml library in test environment"
		header_page = Page.create(:page_layout => 'layout_header', :parent_id => Page.root.id, :layoutpage => true, :language => Language.get_default)
		sitename = Element.create_from_scratch({:name => 'sitename', :page_id => header_page.id})
		sitename.content_by_name('name').essence.update_attributes(:body => 'Peters Petshop')
    visit '/'
		within('head title') { page.should have_content('Peters Petshop') }
  end

end