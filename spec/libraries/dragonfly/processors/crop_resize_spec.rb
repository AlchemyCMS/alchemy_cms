# frozen_string_literal: true

require "rails_helper"
require_relative "../../../support/dragonfly_test_app"

RSpec.describe Alchemy::Dragonfly::Processors::CropResize, if: Alchemy.storage_adapter.dragonfly? do
  let(:app) { dragonfly_test_app }
  let(:file) { fixture_file_upload("80x60.png") }
  let(:image) { Dragonfly::Content.new(app, file) }
  let(:processor) { described_class.new }

  it "validates bad crop and resize arguments" do
    expect {
      processor.call(image, "h4ck", "m3")
    }.to raise_error(Dragonfly::ParamValidators::InvalidParameter)
  end

  it "works with correct crop and resize arguments" do
    expect {
      processor.call(image, "4x4+0+0", "20x20>")
    }.to_not raise_error
  end
end
