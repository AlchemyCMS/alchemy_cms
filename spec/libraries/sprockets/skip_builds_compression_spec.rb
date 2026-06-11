# frozen_string_literal: true

require "rails_helper"
require "sprockets"
require "alchemy/sprockets/skip_builds_compression"

RSpec.describe Alchemy::Sprockets::SkipBuildsCompression do
  let(:compressor_class) do
    Class.new do
      def call(input)
        {data: "compressed(#{input[:data]})"}
      end
      prepend Alchemy::Sprockets::SkipBuildsCompression
    end
  end

  subject(:compress) { compressor_class.new.call(filename: filename, data: "css") }

  context "for a stylesheet inside Alchemy's app/assets/builds" do
    let(:filename) do
      Alchemy::Engine.root.join("app/assets/builds/alchemy/admin.css").to_s
    end

    it "returns the data untouched, skipping compression" do
      expect(compress).to eq(data: "css")
    end
  end

  context "for any other stylesheet" do
    let(:filename) { "/app/app/assets/stylesheets/application.css" }

    it "delegates to the wrapped compressor" do
      expect(compress).to eq(data: "compressed(css)")
    end
  end

  it "is prepended onto Sprockets::SassCompressor" do
    expect(::Sprockets::SassCompressor.singleton_class.ancestors).to include(described_class)
  end
end
