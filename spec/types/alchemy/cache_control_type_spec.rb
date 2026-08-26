# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe CacheControlType do
    subject(:type) { described_class.new }

    describe "#cast" do
      it "casts scalars into a CacheControl" do
        expect(type.cast(true)).to be_a(Alchemy::CacheControl)
        expect(type.cast(false).no_store?).to be(true)
        expect(type.cast(3600).max_age).to eq(3600)
      end

      it "casts a hash into a CacheControl" do
        control = type.cast("visibility" => "private", "max_age" => 60)
        expect(control.private?).to be(true)
        expect(control.max_age).to eq(60)
      end

      it "returns a CacheControl unchanged" do
        control = Alchemy::CacheControl.parse(60)
        expect(type.cast(control)).to equal(control)
      end
    end

    describe "#assert_valid_value" do
      it "accepts scalars and nil" do
        [nil, true, false, 600].each do |value|
          expect { type.assert_valid_value(value) }.not_to raise_error
        end
      end

      it "accepts a valid hash (symbol or string keys)" do
        expect { type.assert_valid_value(visibility: :private, max_age: 60) }.not_to raise_error
        expect { type.assert_valid_value("no_cache" => true, "visibility" => "public") }.not_to raise_error
        expect { type.assert_valid_value(no_store: true) }.not_to raise_error
      end

      it "raises for an unknown key" do
        expect { type.assert_valid_value(bogus: true) }.to raise_error(
          ArgumentError, /unknown cache option.*bogus/i
        )
      end

      it "raises for an invalid visibility" do
        expect { type.assert_valid_value(visibility: "secret") }.to raise_error(
          ArgumentError, /visibility.*public.*private/i
        )
      end

      it "raises for a non-integer max_age" do
        expect { type.assert_valid_value(max_age: "soon") }.to raise_error(
          ArgumentError, /max_age.*integer/i
        )
      end

      it "raises for a negative max_age" do
        expect { type.assert_valid_value(max_age: -5) }.to raise_error(
          ArgumentError, /max_age/i
        )
      end

      it "raises for contradictory no_store + max_age" do
        expect { type.assert_valid_value(no_store: true, max_age: 60) }.to raise_error(
          ArgumentError, /no_store/i
        )
      end

      it "raises for contradictory no_cache + max_age" do
        expect { type.assert_valid_value(no_cache: true, max_age: 60) }.to raise_error(
          ArgumentError, /no_cache/i
        )
      end

      it "raises for a non-boolean no_cache/no_store" do
        expect { type.assert_valid_value(no_cache: "yes") }.to raise_error(
          ArgumentError, /no_cache.*true or false/i
        )
        expect { type.assert_valid_value(no_store: "nope") }.to raise_error(
          ArgumentError, /no_store.*true or false/i
        )
      end

      it "raises for an unsupported type" do
        expect { type.assert_valid_value([1, 2]) }.to raise_error(
          ArgumentError, /not a valid cache setting/i
        )
      end
    end
  end
end
