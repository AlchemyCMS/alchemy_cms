# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::ElementsHelper do
    let(:page)    { build_stubbed(:alchemy_page, :public) }
    let(:element) { build_stubbed(:alchemy_element, page: page) }

    context "partial rendering" do
      it "should render an element editor partial" do
        expect(helper).to receive(:render_element).with(element, :editor)
        helper.render_editor(element)
      end
    end

    describe "#grouped_elements_for_select" do
      let(:elements) do
        [
          mock_model('Element', name: '1', display_name: '1'),
          mock_model('Element', name: '2', display_name: '2')
        ]
      end
      let(:element_definitions) { [{"name" => "1"}, {"name" => "2"}] }
      let(:cell_definitions) { [] }
      let(:page_definition) { {} }

      before do
        allow(page).to receive(:definition).and_return(page_definition)
        allow(Cell).to receive(:definitions).and_return(cell_definitions)
        allow(Element).to receive(:definitions).and_return(element_definitions)
        helper.instance_variable_set('@page', page)
      end

      context "with empty elements array given" do
        it "return an empty array" do
          expect(helper.grouped_elements_for_select([])).to eq([])
        end
      end

      context "with an element collection given" do
        let(:page_definition) do
          {'name' => "foo", 'cells' => ["foo_cell"], 'elements' => []}
        end

        let(:cell_definitions) do
          [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
        end

        it "returns an array of elements grouped by cell for select_tag helper" do
          expect(helper.grouped_elements_for_select(elements)).to eq("Foo cell" => [["1", "1#foo_cell"], ["2", "2#foo_cell"]])
        end

        context "without cells key in page definition" do
          let(:page_definition) do
            {'name' => "foo", "elements" => ["1", "2"]}
          end

          it "returns an empty array" do
            expect(helper.grouped_elements_for_select(elements)).to eq([])
          end
        end

        context "with empty cells in page definition" do
          let(:page_definition) do
            {"name" => "foo", "cells" => [], "elements" => ["1", "2"]}
          end

          it "returns an empty array" do
            expect(helper.grouped_elements_for_select(elements)).to eq([])
          end
        end

        context "with a cell containing no elements" do
          let(:cell_definitions) do
            [{"name" => "empty_cell", "elements" => []}]
          end

          let(:page_definition) do
            {"name" => "foo", "cells" => ["empty_cell"], "elements" => ["1", "2"]}
          end

          it "does not include that cell" do
            expect(helper.grouped_elements_for_select(elements)).to eq("Main content" => [["1", "1"], ["2", "2"]])
          end
        end

        context "with an element in a cell only" do
          let(:elements) do
            [mock_model('Element', name: 'in_cell', display_name: 'In Cell')]
          end

          let(:page_definition) do
            {'name' => "foo", 'cells' => ["foo_cell"], 'elements' => []}
          end

          let(:cell_definitions) do
            [{'name' => "foo_cell", 'elements' => ["in_cell"]}]
          end

          it "returns an option for the element in the cell only" do
            expect(helper.grouped_elements_for_select(elements)).to include("Foo cell" => [["In cell", "in_cell#foo_cell"]])
          end
        end

        context "with the same element in both cell and page" do
          let(:element_definitions) do
            [{"name" => "in_cell_and_page"}]
          end

          let(:elements) do
            [mock_model('Element', name: 'in_cell_and_page', display_name: 'In Cell and Page')]
          end

          let(:page_definition) do
            {
              'name' => "foo",
              'cells' => ["foo_cell"],
              'elements' => ["in_cell_and_page"]
            }
          end

          let(:cell_definitions) do
            [{
              'name' => "foo_cell",
              'elements' => ["in_cell_and_page"]
            }]
          end

          it "returns two options of same element, one for the cell and one for the page" do
            expect(helper.grouped_elements_for_select(elements)).to eq({
              "Main content" => [["In cell and page", "in_cell_and_page"]],
              "Foo cell" => [["In cell and page", "in_cell_and_page#foo_cell"]]
            })
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
      subject { element_editor_classes(element, locals) }

      let(:element) { build_stubbed(:alchemy_element) }
      let(:locals) { Hash.new }

      it "returns css classes for element editor partial" do
        is_expected.to include('element-editor')
      end

      context 'with draggable in locals set to true' do
        let(:locals) { {draggable: true} }
        it { is_expected.to include('draggable') }
      end

      context 'with draggable in locals set to false' do
        let(:locals) { {draggable: false} }
        it { is_expected.to include('not-draggable') }
      end

      context 'with draggable in locals set to nil' do
        let(:locals) { {draggable: nil} }
        it { is_expected.to include('draggable') }
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
