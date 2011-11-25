require 'spec_helper'

describe Alchemy::Admin::ContentsController do

	before(:each) do
		activate_authlogic
		Alchemy::UserSession.create Factory(:admin_user)
	end

	it "should update a content via ajax" do
		@element = Factory(:element)
		post :update, {:id => @element.contents.find_by_name('intro').id, :content => {:body => 'Peters Petshop'}, :format => :js}
		@element.ingredient('intro').should == "Peters Petshop"
	end

end
