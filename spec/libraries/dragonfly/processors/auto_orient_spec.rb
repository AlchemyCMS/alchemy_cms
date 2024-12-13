# frozen_string_literal: true

require "rails_helper"
require_relative "../../../support/dragonfly_test_app"

RSpec.describe Alchemy::Dragonfly::Processors::AutoOrient do
  let(:app) { dragonfly_test_app }
  let(:file) { Pathname.new(File.expand_path("../../../fixtures/80x60.png", __dir__)) }
  let(:image) { Dragonfly::Content.new(app, file) }
  let(:processor) { described_class.new }

  it "works" do
    expect {
      processor.call(image)
    }.to_not raise_error
  end
end
