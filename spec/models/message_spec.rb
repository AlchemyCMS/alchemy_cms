require 'spec_helper'

module Alchemy
  Config.get(:mailer)['fields'].push('email_of_my_boss')
  Config.get(:mailer)['validate_fields'].push('email_of_my_boss')

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

    context "validation of" do
      context "all fields defined in mailer config" do
        it "adds errors on that fields" do
          Config.get(:mailer)['validate_fields'].each do |field|
            expect(message).to have(1).error_on(field)
          end
        end
      end

      context 'field containing email in its name' do
        context "when field has a value" do
          it "adds error notice (is invalid) to the field" do
            message.email_of_my_boss = 'wrong email format'
            expect(message.errors_on(:email_of_my_boss)).to include("is invalid")
          end
        end
        context "when field is blank" do
          it "adds error notice (can't be blank) to the field" do
            expect(message.errors_on(:email_of_my_boss)).to include("can't be blank")
          end
        end
      end
    end
  end
end
