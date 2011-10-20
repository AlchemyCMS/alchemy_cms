require 'spec_helper'

include AlchemyHelper

describe ElementsHelper do

	before(:each) do
		@page = Factory(:public_page)
	  @element = Factory(:element, :page => @page)
	end

  it "should render an element view partial" do
		helper.render_element(@element).should match(/class="article".+id="article_6"/)
  end

	it "should render an element editor partial" do
	  helper.render_editor(@element).should match(/class="content_editor".+id="essence_text_11"/)
	end

	it "should render all elements" do
		@another_element = Factory(:element)
		helper.stub!(:configuration).and_return(true)
		helper.render_elements.should match(/id="header_3.+id="article_5"/)
	end 

	it "should render a unique dom id for element" do
	  helper.element_dom_id(@element).should == "#{@element.name}_#{@element.id}"
	end

	it "should render a picture editor partial" do
		helper.render_picture_editor(@element).should match(/class="essence_picture_editor"/)
	end

	context "in preview mode" do

	  it "should return the data-alchemy-element HTML attribute for element" do
			@preview_mode = true
		  helper.element_preview_code(@element).should == " data-alchemy-element='#{@element.id}'"
		end

		it "should not return the data-alchemy-element HTML attribute if not in preview_mode" do
		  helper.element_preview_code(@element).should_not == " data-alchemy-element='#{@element.id}'"
		end

	end

end
