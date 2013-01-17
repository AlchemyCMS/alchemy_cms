require 'spec_helper'

module Alchemy
  describe Cell do

    let(:cell) { FactoryGirl.build(:cell) }

    context "#available_elements" do

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

    context "#description" do

      context "without a definition for the expected cellname" do

        it "should return an empty Hash" do
          Cell.stub!(:definition_for).and_return({})
          cell.description.should == {}
        end

      end

      context "with a definition found" do

        it "should return the definition Hash" do
          Cell.stub!(:definition_for).and_return({'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']})
          cell.description.should == {'name' => 'test_cell', 'elements' => ['test_element', 'test_element_2']}
        end

      end

    end

  end
end
