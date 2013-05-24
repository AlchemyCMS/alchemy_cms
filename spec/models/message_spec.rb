require 'spec_helper'

module Alchemy
  describe Message do
    let(:message) { Message.new }

    describe '#persisted?' do
      it "should return false" do
        expect(message.persisted?).to eq(false)        
      end
    end
  end
end
