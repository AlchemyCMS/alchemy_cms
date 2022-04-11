# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Message" do
  let(:message) { Alchemy::Message.new }

  describe ".config" do
    it "should return the mailer config" do
      expect(Alchemy::Message.config).to eq(Alchemy::Config.get(:mailer))
    end
  end

  it "has attributes writers and getters for all fields defined in mailer config" do
    Alchemy::Config.get(:mailer)["fields"].each do |field|
      expect(message).to respond_to(field)
      expect(message).to respond_to("#{field}=")
    end
  end

  context "validation of" do
    context "all fields defined in mailer config" do
      it "adds errors on that fields" do
        Alchemy::Config.get(:mailer)["validate_fields"].each do |field|
          expect(message).to_not be_valid
          expect(message.errors[field].size).to eq(1)
        end
      end
    end

    context "field containing email in its name" do
      before do
        stub_alchemy_config(:mailer, {
          fields: %w[email_of_my_boss],
          validate_fields: %w[email_of_my_boss],
        }.with_indifferent_access)
        Alchemy.send(:remove_const, :Message)
        load Alchemy::Engine.root.join("app/models/alchemy/message.rb")
      end

      context "when field has a value" do
        let(:invalid_message) { Alchemy::Message.new }

        before { invalid_message.email_of_my_boss = "wrong email format" }

        it "adds error notice (is invalid) to the field" do
          expect(invalid_message).to_not be_valid
          expect(invalid_message.errors[:email_of_my_boss]).to include("is invalid")
        end
      end

      context "when field is blank" do
        before { message.email_of_my_boss = "" }

        it "adds error notice (can't be blank) to the field" do
          expect(message).to_not be_valid
          expect(message.errors[:email_of_my_boss]).to include("can't be blank")
        end
      end
    end
  end
end
