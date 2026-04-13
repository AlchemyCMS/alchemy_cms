# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe WildcardUrlType do
    subject(:type) { described_class.new }

    describe "#cast" do
      context "with nil" do
        it "returns nil" do
          expect(type.cast(nil)).to be_nil
        end
      end

      context "with a String" do
        let(:result) { type.cast(":slug") }

        it "sets the pattern" do
          expect(result.pattern).to eq(":slug")
        end

        it "defaults params to empty hash" do
          expect(result.params).to eq({})
        end
      end

      context "with a Hash using string keys" do
        let(:result) { type.cast({"pattern" => ":id", "params" => {"id" => "integer"}}) }

        it "sets the pattern" do
          expect(result.pattern).to eq(":id")
        end

        it "sets the params" do
          expect(result.params).to eq({"id" => "integer"})
        end
      end

      context "with a Hash using symbol keys" do
        let(:result) { type.cast({pattern: ":year/:slug", params: {year: "integer"}}) }

        it "sets the pattern" do
          expect(result.pattern).to eq(":year/:slug")
        end

        it "sets the params" do
          expect(result.params).to eq({year: "integer"})
        end
      end

      context "with a Hash without params" do
        let(:result) { type.cast({"pattern" => ":slug"}) }

        it "defaults params to empty hash" do
          expect(result.params).to eq({})
        end
      end

      context "with an unsupported type" do
        it "returns the value as-is" do
          expect(type.cast(42)).to eq(42)
        end
      end
    end

    describe "#assert_valid_value" do
      it "accepts nil" do
        expect { type.assert_valid_value(nil) }.not_to raise_error
      end

      it "accepts a String" do
        expect { type.assert_valid_value(":slug") }.not_to raise_error
      end

      it "accepts a Hash with a pattern" do
        expect { type.assert_valid_value({"pattern" => ":id"}) }.not_to raise_error
      end

      it "raises for an unsupported type" do
        expect { type.assert_valid_value(42) }.to raise_error(
          ArgumentError, /is not a valid wildcard_url/
        )
      end

      it "raises for a Hash without a pattern" do
        expect { type.assert_valid_value({"params" => "integer"}) }.to raise_error(
          ArgumentError, /must include a "pattern" key/
        )
      end

      it "raises for a Hash with a non-string pattern" do
        expect { type.assert_valid_value({"pattern" => 123}) }.to raise_error(
          ArgumentError, /must include a "pattern" key/
        )
      end
    end

    describe WildcardUrlType::Value do
      subject(:value) { described_class.new(pattern: ":id", params: {"id" => "integer"}) }

      describe "#param_keys" do
        it "returns the named parameter keys as symbols" do
          value = described_class.new(pattern: ":year/:slug")
          expect(value.param_keys).to eq([:year, :slug])
        end

        it "returns a single key for a single-segment pattern" do
          value = described_class.new(pattern: ":id")
          expect(value.param_keys).to eq([:id])
        end

        it "ignores static segments" do
          value = described_class.new(pattern: ":uuid/profile")
          expect(value.param_keys).to eq([:uuid])
        end
      end

      describe "#present?" do
        it "returns true when pattern is present" do
          expect(value).to be_present
        end

        context "when pattern is blank" do
          subject(:value) { described_class.new(pattern: "") }

          it { is_expected.not_to be_present }
        end

        context "when pattern is nil" do
          subject(:value) { described_class.new(pattern: nil) }

          it { is_expected.not_to be_present }
        end
      end
    end
  end
end
