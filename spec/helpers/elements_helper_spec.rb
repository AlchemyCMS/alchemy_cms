require 'spec_helper'

include AlchemyHelper

describe ElementsHelper do

	before(:each) do
	  @element = Factory(:element)
	end

  it "should render an element view partial" do
		render_element(@element).should match(/class="article".+id="article_1"/)
  end

	it "should render an element editor partial" do
	  render_editor(@element).should match(/class="content_editor".+id="essence_text_1"/)
	end

	it "should render all elements"

	it "should render a unique dom id for element" do
	  element_dom_id(@element).should == "#{@element.name}_#{@element.id}"
	end

	it "should render a picture editor partial" do
		render_picture_editor(@element).should match(/class="essence_picture_editor"/)
	end

	context "in preview mode" do

	  it "should return the data-alchemy-element HTML attribute for element" do
			@preview_mode = true
		  element_preview_code(@element).should == " data-alchemy-element='#{@element.id}'"
		end

		it "should not return the data-alchemy-element HTML attribute if not in preview_mode" do
		  element_preview_code(@element).should_not == " data-alchemy-element='#{@element.id}'"
		end

	end

end
