require 'spec_helper'

describe Alchemy::Admin::EssencesHelper do

  let(:element) { FactoryGirl.create(:element, :name => 'article', :create_contents_after_create => true) }

  before do
    element.content_by_name('intro').essence.update_attributes(:body => 'hello!')
  end

  it "should render an essence editor" do
    content = element.content_by_name('intro')
    helper.render_essence_editor(content).should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by name" do
    helper.render_essence_editor_by_name(element, 'intro').should match(/input.+type="text".+value="hello!/)
  end

  it "should render an essence editor by type" do
    helper.render_essence_editor_by_type(element, 'EssenceText').should match(/input.+type="text".+value="hello!/)
  end

  describe '#page_selector' do

    let(:contact_form)  { FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true) }
    let(:contact_page)  { FactoryGirl.create(:public_page, :page_layout => 'contact', :name => 'Contact') }
    let(:page_a)        { FactoryGirl.create(:public_page, :name => 'Page A') }
    let(:page_b)        { FactoryGirl.create(:public_page, :name => 'Page B') }
    let(:page_c)        { FactoryGirl.create(:public_page, :name => 'Page C') }

    before do
      helper.session[:language_id] = 1
      contact_page
      page_b
      page_c
      page_a
    end

    context "with only option set to 'standard'" do

      it "should render select tag with standard pages only" do
        output = helper.page_selector(contact_form, 'success_page', :only => 'standard')
        output.should match(/select.*Page A/m)
        output.should_not match(/select.*Contact/m)
      end

      it "should render select tag with pages ordered by name" do
        output = helper.page_selector(contact_form, 'success_page', :only => 'standard')
        output.should match(/select.*Page A.*Page B.*Page C/m)
      end

    end

  end

end
