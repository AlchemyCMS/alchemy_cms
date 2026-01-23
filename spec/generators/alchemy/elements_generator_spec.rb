# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/stream"
require "generators/alchemy/elements/elements_generator"

RSpec.describe Alchemy::Generators::ElementsGenerator do
  include ActiveSupport::Testing::Stream

  around do |example|
    Dir.mktmpdir do |dir|
      @destination = Pathname.new(dir)
      Dir.chdir(@destination) do
        example.run
      end
    end
  end

  let(:destination) { @destination }
  let(:elements_dir) { destination.join("app/views/alchemy/elements") }
  let(:generator_args) { [] }

  subject(:run_generator) do
    capture(:stdout) do
      described_class.start(generator_args, destination_root: destination)
    end
  end

  describe "#create_partials" do
    before do
      allow(Alchemy::ElementDefinition).to receive(:all).and_return(elements)
    end

    context "with elements defined" do
      let(:elements) do
        [
          Alchemy::ElementDefinition.new(
            name: "article",
            ingredients: [{"role" => "headline", "type" => "Headline"}]
          ),
          Alchemy::ElementDefinition.new(
            name: "sidebar",
            ingredients: []
          )
        ]
      end

      it "creates a partial for each element" do
        run_generator

        expect(elements_dir.join("_article.html.erb")).to exist
        expect(elements_dir.join("_sidebar.html.erb")).to exist
      end

      it "generates partials with element_view_for and element name as variable" do
        run_generator

        content = elements_dir.join("_article.html.erb").read
        expect(content).to include("element_view_for(article)")
      end
    end

    context "with underscored element names" do
      let(:elements) do
        [Alchemy::ElementDefinition.new(name: "featured_article", ingredients: [])]
      end

      it "preserves underscores in the partial filename" do
        run_generator

        expect(elements_dir.join("_featured_article.html.erb")).to exist
      end
    end

    context "when ElementDefinition.all returns empty array" do
      let(:elements) { [] }

      it "does not create any partials" do
        run_generator

        expect(Dir.glob(elements_dir.join("_*.html.erb"))).to be_empty
      end
    end

    context "with slim template engine" do
      let(:elements) { [Alchemy::ElementDefinition.new(name: "article", ingredients: [])] }
      let(:generator_args) { ["-e", "slim"] }

      it "creates slim partials" do
        run_generator

        expect(elements_dir.join("_article.html.slim")).to exist
      end
    end

    context "with haml template engine" do
      let(:elements) { [Alchemy::ElementDefinition.new(name: "article", ingredients: [])] }
      let(:generator_args) { ["-e", "haml"] }

      it "creates haml partials" do
        run_generator

        expect(elements_dir.join("_article.html.haml")).to exist
      end
    end

    context "with nestable elements" do
      let(:elements) do
        [Alchemy::ElementDefinition.new(
          name: "container",
          ingredients: [],
          nestable_elements: ["nested_item"]
        )]
      end

      it "includes nested elements rendering in the partial" do
        run_generator

        content = elements_dir.join("_container.html.erb").read
        expect(content).to include("nested_elements")
      end
    end

    context "when partial already exists with different template engine" do
      let(:elements) { [Alchemy::ElementDefinition.new(name: "existing", ingredients: [])] }
      let(:generator_args) { ["--force"] }

      before do
        FileUtils.mkdir_p(elements_dir)
        elements_dir.join("_existing.html.slim").write("= element_view_for(existing)")
      end

      it "uses the existing template engine instead of the default" do
        expect(run_generator).to include("warning", "slim")
        expect(elements_dir.join("_existing.html.erb")).not_to exist
        expect(elements_dir.join("_existing.html.slim")).to exist
      end
    end
  end
end
