require 'spec_helper'

include AlchemyHelper

describe Admin::ElementsHelper do

	before(:each) do
		@page = Factory(:public_page)
	  @element = Factory(:element, :page => @page)
	end

	it "should render an element editor partial" do
	  helper.render_editor(@element).should match(/class="content_editor".+id="essence_text_11"/)
	end

	it "should render a picture editor partial" do
		helper.render_picture_editor(@element).should match(/class="essence_picture_editor"/)
	end

end
