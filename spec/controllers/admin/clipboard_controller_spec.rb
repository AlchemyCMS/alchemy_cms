require 'spec_helper'

describe Admin::ClipboardController do

	before(:each) do
		activate_authlogic
		UserSession.create FactoryGirl.create(:admin_user)
	end

  context "clipboard" do

    it "should not insert the same element twice" do
			pending "We have to spec our models before we write integration tests"
			@page = FactoryGirl.create(:page, :parent_id => Page.rootpage.id)
		  @element = FactoryGirl.create(:element, :page => @page)
			post(:insert, {:remarkable_type => 'element', :remarkable_id => element.id, :format => :js})
			post(:insert, {:remarkable_type => 'element', :remarkable_id => element.id, :format => :js})
			session[:clipboard][:elements].should == [element.id]
    end

  end

end
