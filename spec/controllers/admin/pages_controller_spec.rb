require 'spec_helper'

describe Alchemy::Admin::PagesController do

	before(:each) do
		activate_authlogic
		Alchemy::UserSession.create Factory(:admin_user)
	end

	describe "#flush", :focus => true do

		it "should remove the cache of all pages" do
			post :flush, {:format => :js}
			response.status.should == 200
		end

	end

end
