require 'spec_helper'

module Alchemy
  shared_examples_for "having a hint" do

    describe '#hint' do
      context 'with hint as text' do
        before do
          subject.stub(definition: {'hint' => 'The hint'})
        end

        it "returns the hint" do
          subject.hint.should == 'The hint'
        end
      end

      context 'with hint set to true' do
        before do
          subject.stub(definition: {'hint' => true})
          I18n.stub(t: 'The hint')
        end

        it "returns the hint from translation" do
          subject.hint.should == 'The hint'
        end
      end
    end

  end
end
