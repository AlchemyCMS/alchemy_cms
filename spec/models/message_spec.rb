require 'spec_helper'

module Alchemy
  describe Message do
    let(:message) { Message.new }

    describe '.config' do
      it "should return the mailer config" do
        Config.should_receive(:get).with(:mailer)
        Message.config
      end
    end

    describe '#persisted?' do
      it "should return false" do
        expect(message.persisted?).to eq(false)
      end
    end

    describe '#attributes' do
      it "should call .attributes" do
        Message.should_receive(:attributes)
        message.attributes
      end
    end
  end
end
