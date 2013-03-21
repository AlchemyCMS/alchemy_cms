require 'spec_helper'

module Alchemy
  describe Clipboard do

    let(:clipboard) { Clipboard.new }

    describe "#new" do
      it "should be a hash with empty elements and pages collections" do
        clipboard[:elements].should == []
        clipboard[:pages].should == []
      end
    end

    describe '#push' do
      it "should add item to clipboard category" do
        clipboard.push :elements, {:id => 1}
        clipboard[:elements].should == [{:id => 1}]
      end
    end

    describe '#replace' do

      it "should replace the category items with new item" do
        clipboard.replace(:elements, {:id => 1})
        clipboard[:elements].should == [{:id => 1}]
      end

      it "should replace the category items with new item collection" do
        clipboard.replace(:elements, [{:id => 1}])
        clipboard[:elements].should == [{:id => 1}]
      end

      it "should be aliased with []= " do
        clipboard[:elements] = [{:id => 1}]
        clipboard[:elements].should == [{:id => 1}]
      end

    end

    describe '#empty?' do
      it "should return true if clipboard is empty" do
        clipboard.empty?.should be_true
      end
    end

    context "full clipboard" do

      before do
        clipboard[:elements] = [{:id => 1}, {:id => 2}]
        clipboard[:pages] = [{:id => 2}, {:id => 3}]
      end

      describe "#all" do

        context "with :elements as parameter" do
          it "should return all element items in clipboard" do
            clipboard[:elements].should == [{:id => 1}, {:id => 2}]
          end
        end

        context "with :pages as parameter" do
          it "should return all page items in clipboard" do
            clipboard[:pages].should == [{:id => 2}, {:id => 3}]
          end
        end

      end

      describe '#contains?' do
        it "should return true if elements id is in collection" do
          clipboard.contains?(:elements, 1).should be_true
        end
      end

      describe '#remove' do
        it "should remove item from category collection" do
          clipboard.remove(:elements, 1)
          clipboard[:elements].should == [{:id => 2}]
        end
      end

      describe '#clear' do

        context "passing a category" do
          it "should clear the category collection" do
            clipboard.clear(:elements)
            clipboard[:elements].should be_empty
          end
        end

        context "passing no category" do
          it "should clear the complete clipboard" do
            clipboard.clear
            clipboard.should be_empty
          end
        end

      end

      describe '#get' do
        it "should return element from collection" do
          clipboard[:elements] = [{:id => 1}]
          clipboard.get(:elements, 1).should == {:id => 1}
        end
      end

    end

  end
end
