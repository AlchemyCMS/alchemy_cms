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

        it "raises a NameError" do
          expect { subject.user_class }.to raise_exception(NameError)
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
