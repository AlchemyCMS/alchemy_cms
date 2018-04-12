# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::EssencesHelper do
  let(:element) { build_stubbed(:alchemy_element) }
  let(:content) { build_stubbed(:alchemy_content, element: element, ingredient: 'hello!') }
  let(:essence) { mock_model('EssenceText', link: nil, partial_name: 'essence_text', ingredient: 'hello!') }

  before do
    allow_message_expectations_on_nil
    allow(content).to receive(:essence).and_return(essence)
  end

  describe 'render_essence' do
    subject { render_essence(content) }

    it "renders an essence view partial" do
      is_expected.to have_content 'hello!'
    end

    context 'with editor given as view part' do
      subject { helper.render_essence(content, :editor) }

      before do
        allow(helper).to receive(:content_label)
        allow(content).to receive(:settings).and_return({})
      end

      it "renders an essence editor partial" do
        expect(content).to receive(:form_field_name)
        is_expected.to have_selector 'input[type="text"]'
      end
    end

    context 'if content is nil' do
      let(:content) { nil }

      it "returns empty string" do
        is_expected.to eq('')
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }

        before { allow(Alchemy).to receive(:t).and_return('') }

        it "displays warning" do
          expect(helper).to receive(:warning).and_return('')
          is_expected.to eq('')
        end
      end
    end

    context 'if essence is nil' do
      let(:essence) { nil }

      it "returns empty string" do
        is_expected.to eq('')
      end

      context 'editor given as part' do
        subject { helper.render_essence(content, :editor) }

        before { allow(Alchemy).to receive(:t).and_return('') }

        it "displays warning" do
          expect(helper).to receive(:warning).and_return('')
          is_expected.to eq('')
        end
      end
    end
  end

  describe 'render_essence_view' do
    it "renders an essence view partial" do
      expect(render_essence_view(content)).to have_content 'hello!'
    end
  end

  describe "render_essence_view_by_name" do
    it "renders an essence view partial by content name" do
      expect(element).to receive(:content_by_name).and_return(content)
      expect(render_essence_view_by_name(element, 'intro')).to have_content 'hello!'
    end
  end
end
