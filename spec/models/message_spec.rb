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

    it "has attributes writers and getters for all fields defined in mailer config" do
      Config.get(:mailer)['fields'].each do |field|
        expect(message).to respond_to(field)
        expect(message).to respond_to("#{field}=")
      end
    end

    it "validates attributes defined in mailer config" do
      Config.get(:mailer)['validate_fields'].each do |field|
        expect(message).to have(1).error_on(field)
      end
    end

    it "validates email format" do
      message.email = 'wrong email format'
      expect(message.errors_on(:email)).to include("is invalid")
    end
  end
end
