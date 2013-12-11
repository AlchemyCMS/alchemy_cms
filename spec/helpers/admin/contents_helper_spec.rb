require 'spec_helper'

describe Alchemy::Admin::ContentsHelper do
  let(:element) { build_stubbed(:element, name: 'article') }
  let(:content) { mock_model('Content', essence_partial_name: 'essence_text') }

  describe 'render_content_name' do
    let(:content) do
      mock_model 'Content',
        name: 'intro',
        description: {name: 'intro', type: 'EssenceText'},
        name_for_label: 'Intro',
        has_validations?: false
    end
    subject { helper.render_content_name(content) }

    it "returns the content name" do
      should == "Intro"
    end

    context 'if content is nil' do
      let(:content) { nil }

      it "returns nil" do
        should be_nil
      end
    end

    context 'with missing description' do
      before { content.stub(description: {}) }

      it "renders a warning" do
        should have_selector('span.warning')
        should have_content('Intro')
      end
    end

    context 'with validations' do
      before { content.stub(has_validations?: true) }

      it "show a validation indicator" do
        should have_selector('.validation_indicator')
      end
    end
  end

  describe 'render_new_content_link' do
    subject { helper.render_new_content_link(element) }

    it "renders a link to add new content to element" do
      helper.stub(:render_icon).and_return('')
      should match(/a.+href.*admin\/elements\/#{element.id}\/contents\/new/m)
    end
  end

  describe 'render_create_content_link' do
    subject { helper.render_create_content_link(element, 'headline') }

    it "should render a link to create a content in element" do
      helper.stub(:render_icon).and_return('')
      should have_selector('a.new_content_link[data-method="post"]')
    end
  end

end
