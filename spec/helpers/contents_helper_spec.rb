require 'spec_helper'

describe ContentsHelper do

	before(:each) do
	  @element = Factory(:element)
	end

  it "should render a dom id" do
		content_dom_id(@element.contents.first).should == "essence_text_1"
	end

	it "should render the content name" do
		render_content_name(@element.contents.first).should == "Einleitung"
	end

	it "should render a link to add new content to element" do
		pending "Don't know how to include the alchemy_helper in specs"
	end

	it "should render a link to create a content in element" do
		render_create_content_link(@element).should match(/a.+href.*admin\/contents.+class.+button new_content_link.*data-method.+post/)
	end

end
