require 'spec_helper'

module Alchemy
  describe Cell do
    let(:cell) { build(:alchemy_cell) }

    # class methods

    describe '.definitions' do
      it "should return an Array" do
        expect(Cell.definitions).to be_a(Array)
      end

      it "should allow erb generated definitions" do
        expect(Cell.definitions.collect { |d| d['name'] }).to include('erb_cell')
      end
    end

    describe '.definition_for' do
      subject { Cell.definition_for('right_column') }

      it "returns a definition for given name" do
        eq({'name' => 'right_column', 'elements' => %w(search)})
      end
    end

    describe '.all_definitions_for' do
      subject { Cell.all_definitions_for(%(right_column)) }

      it "returns definitions for given names" do
        eq([{'name' => 'right_column', 'elements' => %w(search)}])
      end
    end

    describe ".definitions_for_element" do
      before do
        allow(Cell).to receive(:definitions).and_return([
          {'name' => 'cell_1', 'elements' => ['target', 'other']},
          {'name' => 'cell_2', 'elements' => ['other', 'other']},
          {'name' => 'cell_3', 'elements' => ['other', 'target']}
        ])
      end

      it "should return all cell definitions that includes the given element name" do
        expect(Cell.definitions_for_element('target')).to eq([
          {'name' => 'cell_1', 'elements' => ['target', 'other']},
          {'name' => 'cell_3', 'elements' => ['other', 'target']}
        ])
      end
    end

    describe '.translated_label_for' do
      subject { Cell.translated_label_for('right_column') }

      it "returns a translated label" do
        eq('Right column')
      end
    end

    # instance methods

    describe "#available_elements" do
      context "without assigned elements" do
        it "should return an empty Array" do
          allow(cell).to receive(:definition).and_return({})
          expect(cell.available_elements).to eq([])
        end
      end

      context "with assigned elements" do
        it "should return an Array of element names" do
          allow(cell).to receive(:definition).and_return({'elements' => ['test_element', 'test_element_2']})
          expect(cell.available_elements).to eq(['test_element', 'test_element_2'])
        end
      end
    end

    describe "#definition" do
      context "without a definition for the expected cellname" do
        it "should return an empty Hash" do
          allow(Cell).to receive(:definition_for).and_return({})
          expect(cell.definition).to eq({})
        end
      end

      context "with a definition for the expected cellname found" do
        it "should return its definition Hash" do
          allow(Cell).to receive(:definition_for).and_return({'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']})
          expect(cell.definition).to eq({'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']})
        end
      end
    end

    describe "#name_for_label" do
      it "should call translated_label_for" do
        expect(Cell).to receive(:translated_label_for).with(cell.name)
        cell.name_for_label
      end
    end

    describe "#elements" do
      context 'with nestable elements' do
        let(:nestable_element) { create(:alchemy_element, :with_nestable_elements) }

        before do
          nestable_element.nested_elements << create(:alchemy_element, name: 'test_element')
          cell.elements << nestable_element
        end

        it 'does not contain nested elements of an element' do
          expect(nestable_element.nested_elements).to_not be_empty
          expect(cell.elements).to_not include(nestable_element.nested_elements.first)
        end
      end
    end
  end
end
