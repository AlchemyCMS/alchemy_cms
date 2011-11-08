require 'spec_helper'

describe Admin::ContentsController do

	before(:each) do
		activate_authlogic
		UserSession.create Factory(:admin_user)
	end

	it "should update a content via ajax" do
		Factory(:element)
		post :update, {:id => 1, :content => {:body => 'Peters Petshop'}, :format => :js}
		Element.first.ingredient('intro').should == "Peters Petshop"
	end

end
