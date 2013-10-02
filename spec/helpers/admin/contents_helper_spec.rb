require 'spec_helper'

describe Alchemy::Admin::ContentsHelper do
  let(:element) { FactoryGirl.create(:element, name: 'article', create_contents_after_create: true) }

  it "should render a dom id" do
    helper.content_dom_id(element.content_by_type('EssenceText')).should match(/essence_text_\d{1,}/)
  end

  describe '#contents_form_field_ids_string' do
    let(:content_1) { double('Alchemy::Content', form_field_id: 'contents_content_1_body') }
    let(:content_2) { double('Alchemy::Content', form_field_id: 'contents_content_2_body') }

    it "renders a jquery selector string of form field ids from given contents" do
      expect(
        helper.contents_form_field_ids_string([content_1, content_2])
      ).to eq('#contents_content_1_body, #contents_content_2_body')
    end
  end

  it "should render the content name" do
    helper.render_content_name(element.content_by_type('EssenceText')).should == "Intro"
  end

  it "should render a link to add new content to element" do
    helper.stub!(:render_icon).and_return('')
    helper.render_new_content_link(element).should match(/a.+href.*admin\/elements\/#{element.id}\/contents\/new/m)
  end

  it "should render a link to create a content in element" do
    helper.stub!(:render_icon).and_return('')
    helper.render_create_content_link(element, 'headline').should match(/a.+href.*admin\/contents.+class.+new_content_link.*data-method.+post/)
  end

end
