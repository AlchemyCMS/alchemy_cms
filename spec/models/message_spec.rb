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

    describe '#email_is_filled' do
      context 'if email attribute is filled' do
        it "should return true" do
          message.stub(:email).and_return('me@you.com')
          expect(message.send(:email_is_filled)).to eq(true)
        end
      end

      context 'if email attribute is not filled' do
        it "should return false" do
          message.stub(:email).and_return('')
          expect(message.send(:email_is_filled)).to eq(false)
        end
      end
    end
  end
end
