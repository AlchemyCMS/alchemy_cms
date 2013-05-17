require 'spec_helper'

module Alchemy
  describe Cell do

    let(:cell) { FactoryGirl.build(:cell) }

    describe "#available_elements" do

      context "without assigned elements" do
        it "should return an empty Array" do
          cell.stub!(:description).and_return({})
          cell.available_elements.should == []
        end
      end

      context "with assigned elements" do
        it "should return an Array of element names" do
          cell.stub!(:description).and_return({'elements' => ['test_element', 'test_element_2']})
          cell.available_elements.should == ['test_element', 'test_element_2']
        end
      end

    end

    describe "#description" do

      context "without a definition for the expected cellname" do
        it "should return an empty Hash" do
          Cell.stub!(:definition_for).and_return({})
          cell.description.should == {}
        end
      end

      context "with a definition for the expected cellname found" do
        it "should return its definition Hash" do
          Cell.stub!(:definition_for).and_return({'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']})
          cell.description.should == {'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']}
        end
      end

    end
    
    describe '.definitions' do
      it "should return an Array" do
        expect(Cell.definitions).to be_a(Array)
      end
    end
    
    describe ".definitions_for_element" do
      before do
        Cell.stub!(:definitions).and_return([
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

  end
end
