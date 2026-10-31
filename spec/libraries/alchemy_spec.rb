require "rails_helper"

RSpec.describe Alchemy do
  describe ".version" do
    subject { Alchemy.version }

    it { is_expected.to eq(Alchemy::VERSION) }
  end

  describe ".gem_version" do
    subject { Alchemy.gem_version }

    it { is_expected.to eq(Gem::Version.new(Alchemy::VERSION)) }
  end

  describe ".git_revision_info" do
    subject { Alchemy.git_revision_info }

    let(:sources) { [source] }

    before do
      allow(Bundler).to receive(:locked_gems).and_return(double(sources: sources))
    end

    context "when the alchemy_cms gem is locked to a git source" do
      let(:source) do
        double(name: "alchemy_cms", revision: "abc1234def5678", branch: "main")
      end

      it "returns the revision and branch" do
        is_expected.to eq(revision: "abc1234def5678", branch: "main")
      end
    end

    context "when the alchemy_cms gem is not locked to a git source" do
      let(:source) { double(name: "alchemy_cms") }

      it { is_expected.to be_nil }
    end

    context "when there is no alchemy_cms source" do
      let(:sources) { [double(name: "another_gem")] }

      it { is_expected.to be_nil }
    end

    context "when reading the lockfile raises an error" do
      let(:sources) { [] }

      before do
        allow(Bundler).to receive(:locked_gems).and_raise(StandardError)
      end

      it { is_expected.to be_nil }
    end
  end

  describe ".config" do
    subject { Alchemy.config }

    it "is a config object" do
      expect(subject).to be_a(Alchemy::Configurations::Main)
    end

    it "has the auto_logout_time from config.yml" do
      expect(subject.auto_logout_time).to eq(40)
    end

    it "has the output_image_quality from test.config.yml" do
      expect(subject.output_image_quality).to eq(85)
    end

    it "has the default image output format" do
      expect(subject.image_output_format).to eq("original")
    end

    describe "format matchers" do
      describe "email" do
        subject { Alchemy.config.format_matchers.email }

        it { is_expected.to match("hello@gmail.com") }
        it { is_expected.not_to match("stulli@gmx") }
      end

      describe "url" do
        subject { Alchemy.config.format_matchers.url }

        it { is_expected.to match("www.example.com:80/about") }
        it { is_expected.not_to match('www.example.com:80\/about') }
      end

      describe "link_url" do
        subject { Alchemy.config.format_matchers.link_url }

        it { is_expected.to match("tel:12345") }
        it { is_expected.to match("mailto:stulli@gmx.de") }
        it { is_expected.to match("/home") }
        it { is_expected.to match("https://example.com/home") }
        it { is_expected.not_to match('\/brehmstierleben') }
        it { is_expected.not_to match('https:\/\/example.com/home') }
      end
    end
  end

  describe "admin_importmaps" do
    subject { Alchemy.config.admin_importmaps }
    it "includes alchemy_admin importmap" do
      expect(subject.first.to_h).to eq({
        importmap_path: Alchemy::Engine.root.join("config/importmap.rb"),
        name: "alchemy_admin",
        source_paths: [
          Alchemy::Engine.root.join("app/javascript"),
          Alchemy::Engine.root.join("vendor/javascript")
        ]
      })
    end
  end

  describe ".configure" do
    subject do
      Alchemy.configure do |config|
        config.auto_logout_time = 500
      end
    end

    around do |example|
      old_auto_logout_time = Alchemy.config.auto_logout_time
      example.run
      Alchemy.config.auto_logout_time = old_auto_logout_time
    end

    it "yields the config object" do
      expect { subject }.to change(Alchemy.config, :auto_logout_time).to(500)
    end
  end
end
