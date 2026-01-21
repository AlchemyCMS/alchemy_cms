# frozen_string_literal: true

require "rails_helper"
require_relative "../../../support/dragonfly_test_app"

RSpec.describe Alchemy::Dragonfly::Processors::Thumbnail, if: Alchemy.storage_adapter.dragonfly? do
  let(:app) { dragonfly_test_app }
  let(:file) { fixture_file_upload("80x60.png") }
  let(:image) { Dragonfly::Content.new(app, file) }
  let(:processor) { described_class.new }
  let(:geometry) { "40x30#" }

  describe "validation" do
    it "works with a valid argument" do
      expect {
        processor.call(image, geometry)
      }.to_not raise_error
    end

    it "validates with invalid argument" do
      expect {
        processor.call(image, "foo")
      }.to raise_error(ArgumentError)
    end
  end

  describe "args_for_geometry" do
    before do
      processor.call(image, geometry)
    end

    context "PNG" do
      it "should not have the coalesce and deconstruct argument" do
        expect(processor.args_for_geometry(geometry)).not_to include("coalesce", "deconstruct")
      end
    end

    context "GIF" do
      let(:file) { fixture_file_upload("animated.gif") }

      it "should have the coalesce and deconstruct argument" do
        expect(processor.args_for_geometry(geometry)).to include("coalesce", "deconstruct")
      end
    end
  end
end
