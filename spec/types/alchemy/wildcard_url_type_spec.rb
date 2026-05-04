# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe WildcardUrlType do
    subject(:type) { described_class.new }

    describe "#cast" do
      it "returns nil for nil" do
        expect(type.cast(nil)).to be_nil
      end

      it "returns the String unchanged" do
        expect(type.cast(":slug")).to eq(":slug")
      end

      it "normalizes a Symbol to a leading-colon String" do
        expect(type.cast(:slug)).to eq(":slug")
      end

      it "returns unsupported values as-is" do
        expect(type.cast(42)).to eq(42)
      end
    end

    describe "#assert_valid_value" do
      it "accepts nil" do
        expect { type.assert_valid_value(nil) }.not_to raise_error
      end

      it "accepts a String" do
        expect { type.assert_valid_value(":slug") }.not_to raise_error
      end

      it "accepts a Symbol" do
        expect { type.assert_valid_value(:slug) }.not_to raise_error
      end

      it "raises for an unsupported value" do
        expect { type.assert_valid_value(42) }.to raise_error(
          ArgumentError, /is not a valid wildcard_url.*Symbol or String/
        )
      end

      it "raises for a Hash" do
        expect { type.assert_valid_value({param: ":id"}) }.to raise_error(
          ArgumentError, /is not a valid wildcard_url.*Symbol or String/
        )
      end

      it "raises for a value containing a slash" do
        expect { type.assert_valid_value(":year/:slug") }.to raise_error(
          ArgumentError, /cannot contain "\/".*single URL segment/
        )
      end

      it "raises for a value without a dynamic segment" do
        expect { type.assert_valid_value("static") }.to raise_error(
          ArgumentError, /must contain a dynamic segment/
        )
      end
    end
  end
end
