require 'spec_helper'

describe Admin::ClipboardController do

	before(:each) do
		activate_authlogic
    user = Factory(:admin_user)
    user.save_without_session_maintenance
		UserSession.create user
	end

  context "clipboard" do

    it "should hold element ids" do
			@page = Factory(:page, :parent_id => Page.rootpage.id)
		  @element = Factory(:element, :page => @page)
		  @another_element = Factory(:element, :page => @page)
			session[:clipboard] = { :elements => [@element.id] }
			post(:insert, {:remarkable_type => 'element', :remarkable_id => @another_element.id, :format => :js})
			session[:clipboard][:elements].should == [@element.id, @another_element.id]
    end

    it "should not have the same element twice" do
			@page = Factory(:page, :parent_id => Page.rootpage.id)
		  @element = Factory(:element, :page => @page)
			session[:clipboard] = { :elements => [@element.id] }
			post(:insert, {:remarkable_type => 'element', :remarkable_id => @element.id, :format => :js})
			session[:clipboard][:elements].should == [@element.id]
    end

    it "should remove element ids" do
			@page = Factory(:page, :parent_id => Page.rootpage.id)
		  @element = Factory(:element, :page => @page)
		  @another_element = Factory(:element, :page => @page)
			session[:clipboard] = { :elements => [@element.id, @another_element.id] }
			delete(:remove, {:remarkable_type => 'element', :remarkable_id => @another_element.id, :format => :js})
			session[:clipboard][:elements].should == [@element.id]
    end

    it "should be clearable" do
			@page = Factory(:page, :parent_id => Page.rootpage.id)
		  @element = Factory(:element, :page => @page)
		  @another_element = Factory(:element, :page => @page)
			session[:clipboard] = { :elements => [@element.id, @another_element.id] }
			delete(:clear, :format => :js)
			session[:clipboard].should == {}
    end

  end

end
