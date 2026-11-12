# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/stream"
require "alchemy/liquid/generators"

RSpec.describe Alchemy::Generators::ElementsGenerator do
  include ActiveSupport::Testing::Stream

  around do |example|
    Dir.mktmpdir do |dir|
      @destination = Pathname.new(dir)
      example.run
    end
  end

  let(:elements_dir) { @destination.join("app/views/alchemy/elements") }

  let(:elements) do
    [
      Alchemy::ElementDefinition.new(
        name: "article",
        ingredients: [
          {"role" => "headline", "type" => "Headline"},
          {"role" => "text", "type" => "Richtext"}
        ]
      ),
      Alchemy::ElementDefinition.new(name: "intro", ingredients: [{"role" => "text", "type" => "Text"}]),
      Alchemy::ElementDefinition.new(name: "slider", ingredients: [], nestable_elements: ["slide"])
    ]
  end

  before do
    allow(Alchemy::ElementDefinition).to receive(:all).and_return(elements)
  end

  subject(:run_generator) do
    capture(:stdout) { described_class.start(["-e", "liquid"], destination_root: @destination) }
  end

  it "creates liquid partials" do
    run_generator
    expect(elements_dir.join("_article.html.liquid")).to exist
    expect(elements_dir.join("_article.html.erb")).not_to exist
  end

  it "renders each ingredient with the ingredient tag" do
    run_generator
    content = elements_dir.join("_article.html.liquid").read
    expect(content).to include("{% cache element %}", "{% element_view element %}")
    expect(content).to include('<div class="headline">', '{% ingredient "headline" %}', '{% ingredient "text" %}')
  end

  it "does not wrap a single ingredient" do
    run_generator
    content = elements_dir.join("_intro.html.liquid").read
    expect(content).to include('{% ingredient "text" %}')
    expect(content).not_to include("<div")
  end

  it "renders nested elements" do
    run_generator
    expect(elements_dir.join("_slider.html.liquid").read).to include("{% elements element.nested_elements %}")
  end

  it "generates templates that parse in strict mode" do
    run_generator
    Dir[elements_dir.join("*.liquid")].each do |file|
      expect { Liquid::Template.parse(File.read(file), environment: Alchemy::Liquid.environment, error_mode: :strict) }.not_to raise_error
    end
  end
end
