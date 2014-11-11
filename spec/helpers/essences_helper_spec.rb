require 'spec_helper'

describe Alchemy::EssencesHelper do
  let(:element) { build_stubbed(:element) }
  let(:content) { build_stubbed(:content, element: element, ingredient: 'hello!') }
  let(:essence) { mock_model('EssenceText', link: nil, partial_name: 'essence_text', ingredient: 'hello!')}

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
        allow(helper).to receive(:label_and_remove_link)
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

        before { allow(helper).to receive(:_t).and_return('') }

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

        before { allow(helper).to receive(:_t).and_return('') }

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

  describe 'content_settings_value' do
    subject { content_settings_value(content, key, options) }

    let(:key) { :key }

    context 'with content having settings' do
      let(:content) { double(settings: {key: 'content_settings_value'}) }

      context 'and empty options' do
        let(:options) { {} }

        it "returns the value for key from content settings" do
          expect(subject).to eq('content_settings_value')
        end
      end

      context 'and nil options' do
        let(:options) { nil }

        it "returns the value for key from content settings" do
          expect(subject).to eq('content_settings_value')
        end
      end

      context 'but same key present in options' do
        let(:options) { {key: 'options_value'} }

        it "returns the value for key from options" do
          expect(subject).to eq('options_value')
        end
      end
    end

    context 'with content having no settings' do
      let(:content) { double(settings: {}) }

      context 'and empty options' do
        let(:options) { {} }

        it { expect(subject).to eq(nil) }
      end

      context 'but key present in options' do
        let(:options) { {key: 'options_value'} }

        it "returns the value for key from options" do
          expect(subject).to eq('options_value')
        end
      end
    end

    context 'with content having settings with string as key' do
      let(:content) { double(settings: {'key' => 'value_from_string_key'}) }
      let(:options) { {} }

      it "returns value" do
        expect(subject).to eq('value_from_string_key')
      end
    end

    context 'with key passed as string' do
      let(:content) { double(settings: {key: 'value_from_symbol_key'}) }
      let(:key)     { 'key' }
      let(:options) { {} }

      it "returns value" do
        expect(subject).to eq('value_from_symbol_key')
      end
    end
  end
end
