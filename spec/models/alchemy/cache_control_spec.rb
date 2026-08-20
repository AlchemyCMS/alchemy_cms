# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe CacheControl do
    describe ".parse" do
      it "treats nil and true as the unconstrained default" do
        [nil, true].each do |value|
          control = described_class.parse(value)
          expect(control.default?).to be(true)
          expect(control.no_store?).to be(false)
          expect(control.no_cache?).to be(false)
          expect(control.max_age).to be_nil
          expect(control.public?).to be(true)
        end
      end

      it "treats false as no_store" do
        control = described_class.parse(false)
        expect(control.no_store?).to be(true)
        expect(control.default?).to be(false)
      end

      it "treats an Integer as a public max_age" do
        control = described_class.parse(3600)
        expect(control.max_age).to eq(3600)
        expect(control.public?).to be(true)
        expect(control.default?).to be(false)
      end

      it "parses a hash with symbol keys" do
        control = described_class.parse(visibility: :private, max_age: 60)
        expect(control.private?).to be(true)
        expect(control.max_age).to eq(60)
      end

      it "parses a hash with string keys and string visibility" do
        control = described_class.parse("visibility" => "private", "max_age" => 60)
        expect(control.private?).to be(true)
        expect(control.max_age).to eq(60)
      end

      it "parses no_cache and no_store hashes" do
        expect(described_class.parse(no_cache: true).no_cache?).to be(true)
        expect(described_class.parse(no_store: true).no_store?).to be(true)
      end

      it "is idempotent for a CacheControl" do
        control = described_class.parse(60)
        expect(described_class.parse(control)).to equal(control)
      end

      it "falls back to the default for unsupported values" do
        expect(described_class.parse("nonsense").default?).to be(true)
      end
    end

    describe "#&" do
      it "no_store wins over everything" do
        a = described_class.parse(3600)
        b = described_class.parse(no_store: true)
        expect((a & b).no_store?).to be(true)
        expect((b & a).no_store?).to be(true)
      end

      it "no_cache wins over a plain max_age" do
        a = described_class.parse(3600)
        b = described_class.parse(no_cache: true)
        expect((a & b).no_cache?).to be(true)
      end

      it "private wins over public" do
        a = described_class.parse(visibility: :public, max_age: 60)
        b = described_class.parse(visibility: :private, max_age: 60)
        expect((a & b).private?).to be(true)
      end

      it "takes the smaller max_age, treating nil as unbounded" do
        expect((described_class.parse(60) & described_class.parse(3600)).max_age).to eq(60)
        expect((described_class.parse(true) & described_class.parse(3600)).max_age).to eq(3600)
        expect((described_class.parse(true) & described_class.parse(true)).max_age).to be_nil
      end
    end

    describe "#restrict_visibility" do
      it "downgrades public to private" do
        expect(described_class.parse(60).restrict_visibility.private?).to be(true)
      end

      it "leaves no_store untouched" do
        control = described_class.parse(no_store: true).restrict_visibility
        expect(control.no_store?).to be(true)
      end

      it "keeps no_cache but makes it private" do
        control = described_class.parse(no_cache: true).restrict_visibility
        expect(control.no_cache?).to be(true)
        expect(control.private?).to be(true)
      end
    end

    describe "#==" do
      it "compares by directives, ignoring default?" do
        expect(described_class.parse(true)).to eq(described_class.new(visibility: :public))
        expect(described_class.parse(60)).not_to eq(described_class.parse(30))
      end
    end

    describe "#hash" do
      it "is equal for equal directives, so instances dedupe as hash keys" do
        expect(described_class.parse(60).hash).to eq(described_class.parse(60).hash)
        expect([described_class.parse(60), described_class.parse(60)].uniq.size).to eq(1)
      end
    end
  end
end
