# frozen_string_literal: true

require 'spec_helper'
require 'alchemy/shell'

module Alchemy
  # Class fixture
  class MyToDoList
    extend Shell
  end

  describe Shell do
    before { allow(MyToDoList).to receive(:puts) }

    describe '.todo' do
      it "should add given string as a todo by delegating to .add_todo" do
        expect(MyToDoList).to receive(:add_todo).with(["", "new todo"])
        MyToDoList.todo("new todo")
      end
    end

    describe '.todos' do
      it "should be an Array" do
        expect(MyToDoList.todos).to be_a(Array)
      end
    end

    describe '.add_todo' do
      it "should add the given string to the .todos array" do
        MyToDoList.add_todo('1')
        MyToDoList.add_todo('2')
        expect(MyToDoList.todos).to eq(['1', '2'])
      end
    end

    describe '.display_todos' do
      context 'if there are todos in the list' do
        before do
          allow(MyToDoList).to receive(:todos).and_return(['My first todo', 'My second todo'])
        end

        it "should log them" do
          expect(MyToDoList).to receive(:log).at_least(1).times
          MyToDoList.display_todos
        end

        it "should iterate through the todos with an index" do
          expect(MyToDoList.todos).to receive(:each_with_index)
          MyToDoList.display_todos
        end
      end

      context 'if there are todos in the list' do
        before do
          allow(MyToDoList).to receive(:todos).and_return([])
        end

        it "should not log anything" do
          expect(MyToDoList).not_to receive(:log)
          MyToDoList.display_todos
        end
      end
    end

    describe '.log' do
      before { Alchemy::Shell.verbose! }

      context 'if the message type is "skip"' do
        it "the output color should be yellow and cleared again" do
          expect(MyToDoList).to receive(:color).with(:yellow)
          expect(MyToDoList).to receive(:color).with(:clear)
          MyToDoList.log('in yellow, please', :skip)
        end
      end

      context 'if the message type is "error"' do
        it "the output color should be yellow and cleared again" do
          expect(MyToDoList).to receive(:color).with(:red)
          expect(MyToDoList).to receive(:color).with(:clear)
          MyToDoList.log('in red, please', :error)
        end
      end

      context 'if the message type is "message"' do
        it "the output color should just be cleared" do
          expect(MyToDoList).to receive(:color).with(:clear)
          MyToDoList.log('cleared, please', :message)
        end
      end

      context 'if no message type is given' do
        it "the output color should be green" do
          expect(MyToDoList).to receive(:color).with(:green)
          expect(MyToDoList).to receive(:color).with(:clear)
          MyToDoList.log('in green, please')
        end
      end
    end

    describe '.color' do
      context 'if given name is a constant of Thor::Shell::Color' do
        before do
          allow(Thor::Shell::Color).to receive(:const_defined?).and_return(true)
        end

        it "should call the constant" do
          expect_any_instance_of(String).to receive(:constantize).and_return('')
          MyToDoList.send(:color, :red)
        end
      end

      context 'if given name is not a defined constant of Thor::Shell::Color' do
        before do
          allow(Thor::Shell::Color).to receive(:const_defined?).and_return(false)
        end

        it "should return en empty string" do
          expect(MyToDoList.send(:color, :not_existing)).to eq('')
        end
      end
    end
  end
end
