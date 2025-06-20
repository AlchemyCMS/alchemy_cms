require "rails_helper"

RSpec.describe Alchemy do
  describe ".admin_importmaps" do
    subject { Alchemy.admin_importmaps }

    it "returns a Set of admin importmaps" do
      is_expected.to be_a(Set)
    end

    it "includes alchemy_admin importmap" do
      expect(subject.first).to eq({
        importmap_path: Alchemy::Engine.root.join("config/importmap.rb"),
        name: "alchemy_admin",
        source_paths: [
          Alchemy::Engine.root.join("app/javascript"),
          Alchemy::Engine.root.join("vendor/javascript")
        ]
      })
    end

    context "with additional importmaps" do
      before do
        Alchemy.admin_importmaps.add({
          importmap_path: Rails.root.join("config/importmap.rb"),
          name: "additional_importmap",
          source_paths: [Rails.root.join("app/javascript")]
        })
      end

      it "adds additional importmap to admin imports" do
        initializer = Alchemy::Engine.initializers.find { _1.name == "alchemy.importmap" }
        expect(Alchemy.admin_js_imports).to receive(:add).with("additional_importmap")
        initializer.run(Rails.application)
      end
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

  describe "deprecated: Config" do
    subject { Alchemy::Config }

    it "is the same as Alchemy.config, but deprecated" do
      expect(Alchemy::Deprecation).to receive(:warn)
      expect(Alchemy::Config).to eq(Alchemy.config)
    end
  end

  describe "legacy configuration methods" do
    around do |example|
      Alchemy::Deprecation.silence { example.run }
    end
    describe ".enable_searchable" do
      it "forwards to config.page_searchable_checkbox" do
        expect do
          Alchemy.enable_searchable = true
        end.to change(Alchemy.config, :show_page_searchable_checkbox).to(true)
        # Reset
        expect do
          Alchemy.enable_searchable = false
        end.to change(Alchemy, :enable_searchable).to(false)
      end
    end
  end
end
