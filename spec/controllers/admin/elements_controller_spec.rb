require 'spec_helper'

describe Alchemy::Admin::ElementsController do

	render_views

	before do
		activate_authlogic
		Alchemy::UserSession.create Factory(:admin_user)
	end

	it "should return a select tag with elements" do
		let(:page) {mock_model('Page', {:id => 1, :urlname => 'lulu'})}
		get :list, {:page_urlname => @page.urlname, :format => :js}
		response.should have_selector('select.elements_from_page_selector option')
		response.should have_content(p.urlname)
	end

end
