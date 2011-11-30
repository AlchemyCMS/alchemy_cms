require 'spec_helper'

describe Alchemy::Admin::ContentsHelper do

	before(:each) do
	  @element = Factory(:element)
	end

  it "should render a dom id" do
		helper.content_dom_id(@element.contents.first).should match(/essence_text_\d{1,}/)
	end

	it "should render the content name" do
		helper.render_content_name(@element.contents.first).should == "Einleitung"
	end

	it "should render a link to add new content to element" do
		helper.render_new_content_link(@element).should match(/Alchemy.openWindow.+\/admin\/elements\/#{@element.id}\/contents\/new/m)
	end

	it "should render a link to create a content in element" do
		helper.render_create_content_link(@element).should match(/a.+href.*admin\/contents.+class.+button new_content_link.*data-method.+post/)
	end

end
