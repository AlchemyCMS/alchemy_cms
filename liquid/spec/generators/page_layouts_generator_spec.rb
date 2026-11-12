# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/stream"
require "alchemy/liquid/generators"

RSpec.describe Alchemy::Generators::PageLayoutsGenerator do
  include ActiveSupport::Testing::Stream

  around do |example|
    Dir.mktmpdir do |dir|
      @destination = Pathname.new(dir)
      example.run
    end
  end

  before do
    allow(Alchemy::PageDefinition).to receive(:all).and_return([Alchemy::PageDefinition.new(name: "news")])
  end

  it "creates liquid page layouts rendering the elements" do
    capture(:stdout) { described_class.start(["-e", "liquid"], destination_root: @destination) }
    file = @destination.join("app/views/alchemy/page_layouts/_news.html.liquid")
    expect(file.read).to eq("{% elements %}\n")
  end

  it "still generates erb by default" do
    capture(:stdout) { described_class.start([], destination_root: @destination) }
    expect(@destination.join("app/views/alchemy/page_layouts/_news.html.erb")).to exist
  end
end
