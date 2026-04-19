# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe PageServiceType do
    subject(:type) { described_class.new }

    # A class without a #call method
    let(:non_service_class) do
      Class.new
    end

    before do
      stub_const("NotAService", non_service_class)
    end

    describe "#cast" do
      context "with nil" do
        it "returns nil" do
          expect(type.cast(nil)).to be_nil
        end
      end

      context "with a valid class name" do
        it "returns the class constant" do
          expect(type.cast("DummyPageService")).to eq(DummyPageService)
        end
      end

      it "raises for a non-existent class" do
        expect { type.cast("DoesNotExist") }.to raise_error(
          ArgumentError, /could not be found/
        )
      end
    end

    describe "#assert_valid_value" do
      it "accepts nil" do
        expect { type.assert_valid_value(nil) }.not_to raise_error
      end

      it "accepts a valid service class name" do
        expect { type.assert_valid_value("DummyPageService") }.not_to raise_error
      end

      it "raises for a non-existent class" do
        expect { type.assert_valid_value("DoesNotExist") }.to raise_error(
          ArgumentError, /could not be found/
        )
      end

      it "raises for a class that is not a subclass of BasePageService" do
        expect { type.assert_valid_value("NotAService") }.to raise_error(
          ArgumentError, /must be a subclass of Alchemy::BasePageService/
        )
      end
    end
  end
end
