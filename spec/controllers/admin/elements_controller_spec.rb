require 'spec_helper'

describe Alchemy::Admin::ElementsController do

	render_views

	before(:each) do
		activate_authlogic
		Alchemy::UserSession.create Factory(:admin_user)
	end

	let(:page) {mock_model('Page', {:id => 1, :urlname => 'lulu'})}
	let(:element) {mock_model('Element', {:id => 1, :page_id => page.id, :public => true, :display_name_with_preview_text => 'lalaa', :dom_id => 1})}

	it "should return a select tag with elements" do
		Alchemy::Page.should_receive(:find_by_urlname_and_language_id).and_return(page)
		Alchemy::Element.should_receive(:find_all_by_page_id_and_public).and_return([element])
		get :list, {:page_urlname => page.urlname, :format => :js}
		response.body.should match(/select(.*)elements_from_page_selector(.*)option/)
	end

end
