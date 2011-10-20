require 'spec_helper'

describe EssencesHelper do

	before(:each) do
	  @element = Factory(:element)
		@element.content_by_name('intro').essence.update_attributes(:body => 'hello!')
	end

	it "should render an essence" do
	  content = @element.content_by_name('intro')
    render_essence(content).should match(/hello!/)
	end

	it "should render an essence view" do
	  content = @element.content_by_name('intro')
    render_essence_view(content).should match(/hello!/)
	end

  it "should render an essence view by name" do
    render_essence_view_by_name(@element, 'intro').should match(/hello!/)
  end

  it "should render an essence view by type" do
    render_essence_view_by_type(@element, 'EssenceText').should match(/hello!/)
  end

  it "should render an essence view by position" do
    render_essence_view_by_position(@element, 1).should match(/hello!/)
  end

	it "should render an essence editor" do
	  content = @element.content_by_name('intro')
    render_essence_editor(content).should match(/input.+type="text".+value="hello!/)
	end

  it "should render an essence editor by name" do
    render_essence_editor_by_name(@element, 'intro').should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by type" do
    render_essence_editor_by_type(@element, 'EssenceText').should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by position" do
    render_essence_editor_by_position(@element, 1).should match(/input.+type="text".+value="hello!/)
  end

end
