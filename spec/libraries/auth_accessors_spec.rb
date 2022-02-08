# frozen_string_literal: true

require "rails_helper"

module Alchemy
  class MyCustomUser
  end

  describe "AuthAccessors" do
    describe ".user_class_name" do
      before do
        Alchemy.user_class_name = "DummyClassName"
      end

      it "raises error if user_class_name is not a String" do
        Alchemy.user_class_name = DummyUser
        expect {
          Alchemy.user_class_name
        }.to raise_error(TypeError)
      end

      it "returns user_class_name with :: prefix" do
        expect(Alchemy.user_class_name).to eq("::DummyClassName")
      end
    end

    describe ".user_class" do
      context "with no custom user_class_name set" do
        before do
          Alchemy.user_class_name = "User"
        end

        context "and the default user class exists" do
          class ::User; end

          it "returns the default user class" do
            expect(Alchemy.user_class).to be(::User)
          end
        end

        context "and the default user class does not exist" do
          before do
            if Object.constants.include?(:User)
              Object.send(:remove_const, :User)
            end
          end

          it "returns nil" do
            expect(Alchemy.user_class).to be_nil
          end

          it "logs warning" do
            expect(Rails.logger).to receive(:warn).with(a_string_matching("AlchemyCMS cannot find any user class"))
            Alchemy.user_class
          end
        end
      end

      context "with custom user_class_name set" do
        before do
          Alchemy.user_class_name = "DummyUser"
        end

        context "and the custom User class exists" do
          it "returns the custom user class" do
            expect(Alchemy.user_class).to be(::DummyUser)
          end
        end

        context "and the custom user class does not exist" do
          before do
            Alchemy.user_class_name = "NoUser"
          end

          it "returns nil" do
            expect(Alchemy.user_class).to be_nil
          end

          it "logs warning" do
            expect(Rails.logger).to receive(:warn).with(a_string_matching("AlchemyCMS cannot find any user class"))
            Alchemy.user_class
          end
        end
      end
    end

    describe "defaults" do
      it "has default value for Alchemy.user_class_primary_key" do
        expect(Alchemy.user_class_primary_key).to eq(:id)
      end

      it "has default value for Alchemy.signup_path" do
        expect(Alchemy.signup_path).to eq("/signup")
      end

      it "has default value for Alchemy.login_path" do
        expect(Alchemy.login_path).to eq("/login")
      end

      it "has default value for Alchemy.logout_path" do
        expect(Alchemy.logout_path).to eq("/logout")
      end

      it "has default value for Alchemy.logout_method" do
        expect(Alchemy.logout_method).to eq("delete")
      end
    end

    after do
      Alchemy.user_class_name = "DummyUser"
      Alchemy.class_variable_set("@@user_class", nil)
    end
  end
end
