require 'spec_helper'

describe Alchemy::Admin::ContentsHelper do

  before(:each) do
    @element = FactoryGirl.create(:element, :name => 'article')
  end

  it "should render a dom id" do
    helper.content_dom_id(@element.content_by_type('EssenceText')).should match(/essence_text_\d{1,}/)
  end

  it "should render the content name" do
    helper.render_content_name(@element.content_by_type('EssenceText')).should == "Intro"
  end

  it "should render a link to add new content to element" do
    helper.stub!(:render_icon).and_return('')
    helper.render_new_content_link(@element).should match(/a.+href.*admin\/elements\/#{@element.id}\/contents\/new/m)
  end

  it "should render a link to create a content in element" do
    helper.render_create_content_link(@element).should match(/a.+href.*admin\/contents.+class.+button new_content_link.*data-method.+post/)
  end

end
