require 'spec_helper'

describe Admin::TrashController do

	render_views

	before(:each) do
		activate_authlogic
		UserSession.create Factory(:admin_user)
	end

	it "should hold trashed elements", :focus => true do
		@page = Factory(:page, :parent_id => Page.rootpage.id)
		@element = Factory(:element, :page => nil, :public => false, :position => 0, :folded => true)
		get :index, :page_id => @page.id
		response.body.should have_selector('#trash_items #element_4.element_editor')
	end

end
