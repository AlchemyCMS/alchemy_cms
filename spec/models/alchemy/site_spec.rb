# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Site do
    let(:site) { create(:alchemy_site) }

    describe "new instances" do
      subject { build(:alchemy_site, host: "bla.com") }

      it "should start out with no languages" do
        expect(subject.languages).to be_empty
      end

      context "when being saved" do
        context "when it already has a language" do
          let(:language) { build(:alchemy_language, site: nil) }
          before { subject.languages << language }

          it "should not create any additional languages" do
            expect(subject.languages).to eq([language])

            expect { subject.save! }
              .to_not change(subject, "languages")
          end
        end
      end
    end

    describe ".find_for_host" do
      # No need to create a default site, as it has already been added through the seeds.
      # But let's add some more:
      #
      let(:default_site) { Site.first }
      let!(:magiclabs_site) { create(:alchemy_site, host: "www.magiclabs.de", aliases: "magiclabs.de magiclabs.com www.magiclabs.com") }

      subject { Site.find_for_host(host) }

      context "when the request doesn't match anything" do
        let(:host) { "oogabooga.com" }
        it { is_expected.to eq(default_site) }
      end

      context "when the request matches a site's host field" do
        let(:host) { "www.magiclabs.de" }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches one of the site's aliases" do
        let(:host) { "magiclabs.com" }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches the site's first alias" do
        let(:host) { "magiclabs.de" }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request matches the site's last alias" do
        let(:host) { "www.magiclabs.com" }
        it { is_expected.to eq(magiclabs_site) }
      end

      context "when the request host matches only part of a site's aliases" do
        let(:host) { "labs.com" }
        it { is_expected.to eq(default_site) }
      end
    end

    describe ".definitions" do
      # To prevent memoization across specs
      before { Site.instance_variable_set(:@definitions, nil) }

      subject { Site.definitions }

      context "with file present" do
        let(:definitions) { [{"name" => "lala"}] }
        before { expect(YAML).to receive(:load_file).and_return(definitions) }
        it { is_expected.to eq(definitions) }
      end

      context "with empty file" do
        before { expect(YAML).to receive(:load_file).and_return(false) }
        it { is_expected.to eq([]) }
      end

      context "with no file present" do
        it { is_expected.to eq([]) }
      end
    end

    describe "#current?" do
      let!(:default_site) { create(:alchemy_site, :default) }

      let!(:another_site) do
        create(:alchemy_site, name: "Another Site", host: "another.com")
      end

      subject { default_site.current? }

      context "when Current.site is set to the same site" do
        before { Current.site = default_site }
        it { is_expected.to be(true) }
      end

      context "when Current.site is set to nil" do
        before { Current.site = nil }
        it { is_expected.to be(true) }
      end

      context "when Current.site is set to a different site" do
        before { Current.site = another_site }
        it { is_expected.to be(false) }
      end
    end

    describe "#to_partial_path" do
      let(:site) { Site.new(name: "My custom site") }

      it "returns the path to partial" do
        expect(site.to_partial_path).to eq("alchemy/site_layouts/my_custom_site")
      end
    end

    describe "#partial_name" do
      let(:site) { Site.new(name: "My custom site") }

      it "returns the name for layout partial" do
        expect(site.partial_name).to eq("my_custom_site")
      end
    end

    describe "#definition" do
      let(:site) { Site.new(name: "My custom site") }
      let(:definitions) { [{"name" => "my_custom_site", "page_layouts" => %w[standard]}] }

      it "returns layout definition from site_layouts.yml file" do
        allow(Site).to receive(:definitions).and_return(definitions)
        expect(site.definition).to eq(definitions.first)
      end
    end

    describe "#page_layout_names" do
      before do
        Alchemy::PageDefinition.instance_variable_set(:@definitions, nil)
      end

      context "if site has a layout definition file" do
        let(:site) { Site.new(name: "My custom site") }
        let(:definitions) { [{"name" => "my_custom_site", "page_layouts" => %w[standard footer]}] }

        before do
          allow(Site).to receive(:definitions).and_return(definitions)
        end

        it "returns all non 'layoutpage' page layout names" do
          expect(site.page_layout_names).to eq(%w[standard])
        end

        context "when layoutpages are requested" do
          it "returns all 'layoutpage' page layout names" do
            expect(site.page_layout_names(layoutpages: true)).to eq(%w[footer])
          end
        end
      end

      context "if site has no layout definition file" do
        let(:site) { Site.new(name: "My custom site") }

        it "returns all non 'layoutpage' page layout names" do
          allow(Site).to receive(:definitions).and_return([])
          expect(site.page_layout_names).to eq(%w[index readonly standard everything news search contact erb_layout])
        end

        context "when layoutpages are requested" do
          it "returns all 'layoutpage' page layout names" do
            allow(Site).to receive(:definitions).and_return([])
            expect(site.page_layout_names(layoutpages: true)).to eq(%w[footer])
          end
        end
      end
    end

    describe "#page_layout_definitions" do
      before do
        Alchemy::PageDefinition.instance_variable_set(:@definitions, nil)
      end

      context "if site has a layout definition file" do
        let(:site) { Site.new(name: "My custom site") }
        let(:definitions) { [{"name" => "my_custom_site", "page_layouts" => %w[standard]}] }

        it "returns page layouts defined" do
          allow(Site).to receive(:definitions).and_return(definitions)
          expect(site.page_layout_definitions.map(&:name)).to match_array(["standard"])
        end
      end

      context "if site has no layout definition file" do
        let(:site) { Site.new(name: "My custom site") }

        it "returns all page layout definitions" do
          allow(Site).to receive(:definitions).and_return([])
          expect(site.page_layout_definitions.map(&:name)).to match_array([
            "index",
            "readonly",
            "standard",
            "everything",
            "news",
            "contact",
            "footer",
            "erb_layout",
            "search"
          ])
        end
      end
    end

    describe "#default_language" do
      let!(:default_language) do
        create(:alchemy_language, default: true, site: site)
      end

      let!(:other_language) do
        create(:alchemy_language, :german, default: false, site: site)
      end

      subject(:site_default_language) do
        site.default_language
      end

      it "returns the default language of site", :aggregate_failures do
        expect(site.languages.count).to eq(2)
        expect(site_default_language).to eq(default_language)
        expect(site_default_language).to_not eq(other_language)
      end
    end

    describe "#destroy" do
      let(:site) { create(:alchemy_site) }

      subject { site.destroy }

      context "without languages" do
        it "works" do
          subject
          expect(site.errors[:languages]).to be_empty
        end
      end

      context "with languages" do
        let!(:language) { create(:alchemy_language, site: site) }

        it "must not work" do
          subject
          expect(site.errors[:languages]).to_not be_empty
        end
      end
    end
  end
end
