# frozen_string_literal: true

require "rails_helper"
require "active_support/testing/stream"
require "generators/alchemy/page_layouts/page_layouts_generator"

RSpec.describe Alchemy::Generators::PageLayoutsGenerator do
  include ActiveSupport::Testing::Stream

  around do |example|
    Dir.mktmpdir do |dir|
      @destination = Pathname.new(dir)
      # Run all tests from destination so Dir.glob in conditional_template works
      Dir.chdir(@destination) do
        example.run
      end
    end
  end

  let(:destination) { @destination }
  let(:layouts_dir) { destination.join("app/views/alchemy/page_layouts") }
  let(:generator_args) { [] }

  subject(:run_generator) do
    capture(:stdout) do
      described_class.start(generator_args, destination_root: destination)
    end
  end

  describe "#create_partials" do
    before do
      allow(Alchemy::PageDefinition).to receive(:all).and_return(page_layouts)
    end

    context "with page layouts defined" do
      let(:page_layouts) do
        [
          Alchemy::PageDefinition.new(name: "standard"),
          Alchemy::PageDefinition.new(name: "contact")
        ]
      end

      it "creates a partial for each page layout" do
        run_generator

        expect(layouts_dir.join("_standard.html.erb")).to exist
        expect(layouts_dir.join("_contact.html.erb")).to exist
      end

      it "generates partials with render_elements content" do
        run_generator

        content = layouts_dir.join("_standard.html.erb").read
        expect(content).to include("<%= render_elements %>")
      end
    end

    context "with underscored layout names" do
      let(:page_layouts) do
        [Alchemy::PageDefinition.new(name: "news_archive")]
      end

      it "preserves underscores in the partial filename" do
        run_generator

        expect(layouts_dir.join("_news_archive.html.erb")).to exist
      end
    end

    context "when PageDefinition.all returns nil" do
      let(:page_layouts) { nil }

      it "does not create any partials" do
        run_generator

        expect(layouts_dir).not_to exist
      end
    end

    context "when PageDefinition.all returns empty array" do
      let(:page_layouts) { [] }

      it "does not create any partials" do
        run_generator

        expect(Dir.glob(layouts_dir.join("_*.html.erb"))).to be_empty
      end
    end

    context "with slim template engine" do
      let(:page_layouts) { [Alchemy::PageDefinition.new(name: "standard")] }
      let(:generator_args) { ["-e", "slim"] }

      it "creates slim partials" do
        run_generator

        expect(layouts_dir.join("_standard.html.slim")).to exist
      end
    end

    context "with haml template engine" do
      let(:page_layouts) { [Alchemy::PageDefinition.new(name: "standard")] }
      let(:generator_args) { ["-e", "haml"] }

      it "creates haml partials" do
        run_generator

        expect(layouts_dir.join("_standard.html.haml")).to exist
      end
    end

    context "when partial already exists with different template engine" do
      let(:page_layouts) { [Alchemy::PageDefinition.new(name: "existing")] }
      let(:generator_args) { ["--force"] }

      before do
        FileUtils.mkdir_p(layouts_dir)
        layouts_dir.join("_existing.html.slim").write("= render_elements")
      end

      it "uses the existing template engine instead of the default" do
        expect(run_generator).to include("warning", "slim")
        expect(layouts_dir.join("_existing.html.erb")).not_to exist
        expect(layouts_dir.join("_existing.html.slim")).to exist
      end
    end
  end
end
