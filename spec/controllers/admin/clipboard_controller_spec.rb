require 'spec_helper'

describe Alchemy::Admin::ClipboardController do

  before(:each) do
    activate_authlogic
    Alchemy::UserSession.create(Factory(:admin_user))
  end

  context "clipboard" do

    it "should hold element ids" do
      @page = Factory(:page, :parent_id => Alchemy::Page.rootpage.id)
      @element = Factory(:element, :page => @page)
      @another_element = Factory(:element, :page => @page)
      session['clipboard'] = {'elements' => [{:id => @element.id, :action => 'copy'}]}
      post(:insert, {:remarkable_type => 'element', :remarkable_id => @another_element.id, :format => :js})
      session['clipboard']['elements'].should == [{:id => @element.id, :action => 'copy'}, {:id => @another_element.id.to_s, :action => 'copy'}]
    end

    it "should not have the same element twice" do
      @page = Factory(:page, :parent_id => Alchemy::Page.rootpage.id)
      @element = Factory(:element, :page => @page)
      session['clipboard'] = {'elements' => [{:id => @element.id, :action => 'copy'}]}
      post(:insert, {:remarkable_type => 'element', :remarkable_id => @element.id, :format => :js})
      session['clipboard']['elements'].should == [{:id => @element.id, :action => 'copy'}]
    end

    it "should remove element ids" do
      @page = Factory(:page, :parent_id => Alchemy::Page.rootpage.id)
      @element = Factory(:element, :page => @page)
      @another_element = Factory(:element, :page => @page)
      session['clipboard'] = {'elements' => [{:id => @element.id, :action => 'copy'}, {:id => @another_element.id, :action => 'copy'}]}
      delete(:remove, {:remarkable_type => 'element', :remarkable_id => @another_element.id, :format => :js})
      session['clipboard']['elements'].should == [{:id => @element.id, :action => 'copy'}]
    end

    it "should be clearable" do
      @page = Factory(:page, :parent_id => Alchemy::Page.rootpage.id)
      @element = Factory(:element, :page => @page)
      @another_element = Factory(:element, :page => @page)
      session['clipboard'] = {'elements' => [@element.id, @another_element.id]}
      delete(:clear, :format => :js)
      session['clipboard'].should == {}
    end

  end

end
