require 'spec_helper'

describe Alchemy::EssencesHelper do
  let(:element) { build_stubbed(:element) }
  let(:content) { build_stubbed(:content, element: element, ingredient: 'hello!') }
  let(:essence) { mock_model('EssenceText', link: nil, partial_name: 'essence_text', ingredient: 'hello!')}

  before do
    allow_message_expectations_on_nil
    content.stub(:essence).and_return(essence)
  end

  describe 'render_essence' do
    subject { render_essence(content) }

    it "renders an essence view partial" do
      should have_content 'hello!'
    end

    context 'with editor given as view part' do
      subject { helper.render_essence(content, :editor) }

      before do
        helper.stub(:label_and_remove_link)
        content.stub(:settings).and_return({})
      end

      it "renders an essence editor partial" do
        content.should_receive(:form_field_name)
        should have_selector 'input[type="text"]'
      end
    end

    context 'if content is nil' do
      let(:content) { nil }

      it "returns empty string" do
        should == ''
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }
        before { helper.stub(_t: '') }

        it "displays warning" do
          helper.should_receive(:warning).and_return('')
          should == ''
        end
      end
    end

    context 'if essence is nil' do
      let(:essence) { nil }

      it "returns empty string" do
        should == ''
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }
        before { helper.stub(_t: '') }

        it "displays warning" do
          helper.should_receive(:warning).and_return('')
          should == ''
        end
      end
    end
  end

  describe 'render_essence_view' do
    it "renders an essence view partial" do
      render_essence_view(content).should have_content 'hello!'
    end
  end

  describe "render_essence_view_by_name" do
    it "renders an essence view partial by content name" do
      element.should_receive(:content_by_name).and_return(content)
      render_essence_view_by_name(element, 'intro').should have_content 'hello!'
    end
  end
end
