# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  describe Admin::ElementsHelper do
    let(:page)    { build_stubbed(:alchemy_page, :public) }
    let(:element) { build_stubbed(:alchemy_element, page: page) }

    describe "#render_editor" do
      subject { render_editor(element) }

      context 'with nil element' do
        let(:element) { nil }

        it { is_expected.to be_nil }
      end

      context 'with element record given' do
        let(:element) do
          create(:alchemy_element, :with_contents, name: 'headline')
        end

        it "renders the element's editor partial" do
          is_expected.to have_selector('div.content_editor > label', text: 'Headline')
        end

        context 'with element editor partial not found' do
          let(:element) { build_stubbed(:alchemy_element, name: 'not_present') }

          it "renders the editor not found partial" do
            is_expected.to have_selector('div.warning')
            is_expected.to have_content('Element editor partial not found')
          end
        end
      end
    end

    describe "#elements_for_select" do
      context "passing element instances" do
        let(:element_objects) do
          [
            mock_model('Element', name: 'element_1', display_name: 'Element 1'),
            mock_model('Element', name: 'element_2', display_name: 'Element 2')
          ]
        end

        it "should return a array for option tags" do
          expect(helper.elements_for_select(element_objects)).to include(['Element 1', 'element_1'])
          expect(helper.elements_for_select(element_objects)).to include(['Element 2', 'element_2'])
        end
      end

      context "passing a hash with element definitions" do
        let(:element_definitions) do
          [{
            'name' => 'headline',
            'contents' => []
          }]
        end

        subject { helper.elements_for_select(element_definitions) }

        it "should return a array for option tags" do
          expect(subject).to include(['Headline', 'headline'])
        end

        it "should render the elements display name" do
          expect(Element).to receive(:display_name_for).with('headline')
          subject
        end
      end
    end

    describe '#element_editor_classes' do
      subject { element_editor_classes(element) }

      let(:element) { build_stubbed(:alchemy_element) }

      it "returns css classes for element editor partial" do
        is_expected.to include('element-editor')
      end

      context 'with element is folded' do
        let(:element) { build_stubbed(:alchemy_element, folded: true) }
        it { is_expected.to include('folded') }
      end

      context 'with element is expanded' do
        let(:element) { build_stubbed(:alchemy_element, folded: false) }
        it { is_expected.to include('expanded') }
      end

      context 'with element is taggable' do
        before do
          allow(element).to receive(:taggable?) { true }
        end

        it { is_expected.to include('taggable') }
      end

      context 'with element is not taggable' do
        before do
          allow(element).to receive(:taggable?) { false }
        end

        it { is_expected.to include('not-taggable') }
      end

      context 'with element having content_definitions' do
        before do
          allow(element).to receive(:content_definitions) { [1] }
        end

        it { is_expected.to include('with-contents') }
      end

      context 'with element not having content_definitions' do
        before do
          allow(element).to receive(:content_definitions) { [] }
        end

        it { is_expected.to include('without-contents') }
      end

      context 'with element having nestable_elements' do
        before do
          allow(element).to receive(:nestable_elements) { [1] }
        end

        it { is_expected.to include('nestable') }
      end

      context 'with element not having nestable_elements' do
        before do
          allow(element).to receive(:nestable_elements) { [] }
        end

        it { is_expected.to include('not-nestable') }
      end
    end

    describe "#show_element_footer?" do
      subject { show_element_footer?(element, nestable_elements) }
      let(:element) { build_stubbed(:alchemy_element) }
      let(:nestable_elements) { nil }

      context "for folded element" do
        before { allow(element).to receive(:folded?) { true } }
        it { is_expected.to eq(false) }
      end

      context "for expanded element" do
        before { allow(element).to receive(:folded?) { false } }

        context "with nestable_elements argument" do
          let(:nestable_elements) { true }

          context "and element having contents defined" do
            before { allow(element).to receive(:content_definitions) { [1] } }
            it { is_expected.to eq(true) }
          end

          context "and element having no contents defined" do
            before { allow(element).to receive(:content_definitions) { [] } }

            context "and element beeing taggable" do
              before { allow(element).to receive(:taggable?) { true } }
              it { is_expected.to eq(true) }
            end

            context "and element not beeing taggable" do
              before { allow(element).to receive(:taggable?) { false } }
              it { is_expected.to eq(false) }
            end
          end
        end

        context "without nestable_elements argument" do
          let(:nestable_elements) { nil }

          context "and element having no nestable elements defined" do
            before { allow(element).to receive(:nestable_elements) { [] } }
            it { is_expected.to eq(true) }
          end

          context "and element having nestable elements defined" do
            before { allow(element).to receive(:nestable_elements) { [1] } }
            it { is_expected.to eq(false) }
          end
        end
      end
    end
  end
end
