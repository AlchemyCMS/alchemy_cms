# frozen_string_literal: true

require "rails_helper"
require_relative "../../../support/dragonfly_test_app"

# Only loadable with the dragonfly gem installed
if Alchemy.storage_adapter.dragonfly?
  RSpec.describe Alchemy::Dragonfly::Processors::AutoOrient do
    let(:app) { dragonfly_test_app }
    let(:file) { fixture_file_upload("80x60.png") }
    let(:image) { Dragonfly::Content.new(app, file) }
    let(:processor) { described_class.new }

    it "works" do
      expect {
        processor.call(image)
      }.to_not raise_error
    end
  end
end
