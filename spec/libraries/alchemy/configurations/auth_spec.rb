# frozen_string_literal: true

require "rails_helper"

User = Class.new

module Alchemy
  class MyCustomUser
  end

  describe Configurations::Auth do
    subject { described_class.new }

    describe ".user_class" do
      before do
        subject.user_class = "Alchemy::MyCustomUser"
      end

      it "raises error if user_class is not a String" do
        expect {
          subject.user_class = DummyUser
        }.to raise_error(Alchemy::Configuration::ConfigurationError)
      end

      it "returns user_class_name with :: prefix" do
        expect(subject.user_class_name).to eq("::Alchemy::MyCustomUser")
      end
    end

    describe ".user_class" do
      context "with no custom user_class_name set" do
        context "and the default user class exists" do
          it "returns the default user class" do
            expect(subject.user_class).to be(::User)
          end
        end

        context "and the default user class does not exist" do
          before do
            if Object.constants.include?(:User)
              Object.send(:remove_const, :User)
            end
          end

          it "returns nil" do
            expect(subject.user_class).to be_nil
          end

          it "logs warning" do
            expect(Rails.logger).to receive(:warn).with(a_string_matching("AlchemyCMS cannot find any user class"))
            subject.user_class
          end
        end
      end

      context "with custom user_class  set" do
        before do
          subject.user_class = "DummyUser"
        end

        context "and the custom User class exists" do
          it "returns the custom user class" do
            expect(subject.user_class).to be(::DummyUser)
          end
        end

        context "and the custom user class does not exist" do
          before do
            subject.user_class = "NoUser"
          end

          it "returns nil" do
            expect(subject.user_class).to be_nil
          end

          it "logs warning" do
            expect(Rails.logger).to receive(:warn).with(a_string_matching("AlchemyCMS cannot find any user class"))
            subject.user_class
          end
        end
      end
    end

    describe "defaults" do
      it "has default value for user_class_primary_key" do
        expect(subject.user_class_primary_key).to eq(:id)
      end

      it "has default value for signup_path" do
        expect(subject.signup_path).to eq("/signup")
      end

      it "has default value for login_path" do
        expect(subject.login_path).to eq("/login")
      end

      it "has default value for logout_path" do
        expect(subject.logout_path).to eq("/logout")
      end

      it "has default value for logout_method" do
        expect(subject.logout_method).to eq("delete")
      end
    end
  end
end
