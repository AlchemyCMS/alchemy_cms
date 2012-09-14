require 'spec_helper'

describe Alchemy::Admin::TrashController do

	render_views

	before(:each) do
		activate_authlogic
		Alchemy::UserSession.create FactoryGirl.create(:admin_user)
	end

	it "should hold trashed elements" do
		@page = FactoryGirl.create(:page, :parent_id => Alchemy::Page.rootpage.id)
		@element = FactoryGirl.create(:element, :page => nil, :public => false, :position => 0, :folded => true)
		get :index, :page_id => @page.id
		response.body.should have_selector("#trash_items #element_#{@element.id}.element_editor")
	end

end
