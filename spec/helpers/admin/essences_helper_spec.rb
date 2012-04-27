require 'spec_helper'

describe Alchemy::Admin::EssencesHelper do

  before(:each) do
    @element = FactoryGirl.create(:element, :name => 'article')
    @element.content_by_name('intro').essence.update_attributes(:body => 'hello!')
  end

  it "should render an essence editor" do
    content = @element.content_by_name('intro')
    helper.render_essence_editor(content).should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by name" do
    helper.render_essence_editor_by_name(@element, 'intro').should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by type" do
    helper.render_essence_editor_by_type(@element, 'EssenceText').should match(/input.+type="text".+value="hello!/)
  end

end
