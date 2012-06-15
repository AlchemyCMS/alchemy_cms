require 'spec_helper'

describe Admin::TrashController do

	before(:each) do
		activate_authlogic
		UserSession.create FactoryGirl.create(:admin_user)
	end

	it "should hold trashed elements" do
		pending "The controller behaves correct, the test not."
		@page = FactoryGirl.create(:page, :parent_id => Page.rootpage.id)
	  @element = FactoryGirl.create(:element, :page => @page)
		# Rails, RSpec and co. are sucking
		@element.reload
		@element.trash
		@element.reload
		get :index, :page_id => @page.id
		response.body.should have_selector('#trash_items #element_4.element_editor')
	end

end
