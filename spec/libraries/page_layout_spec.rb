# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe PageLayout do
    describe ".all" do
      # skip memoization
      before { PageLayout.instance_variable_set("@definitions", nil) }

      subject { PageLayout.all }

      it "should return all page_layouts" do
        is_expected.to be_instance_of(Array)
        expect(subject.collect { |l| l["name"] }).to include("standard")
      end

      it "should allow erb generated layouts" do
        expect(subject.collect { |l| l["name"] }).to include("erb_layout")
      end

      context "with a YAML file including a symbol" do
        let(:yaml) { "name: :symbol" }
        before do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(yaml)
        end

        it "returns the definition without error" do
          expect { subject }.to_not raise_error
        end
      end

      context "with empty layouts file" do
        before { expect(YAML).to receive(:safe_load).and_return(false) }

        it "returns empty array" do
          is_expected.to eq([])
        end
      end

      context "with missing layouts file" do
        before { expect(File).to receive(:exist?).and_return(false) }

        it "raises error empty array" do
          expect { subject }.to raise_error(LoadError)
        end
      end
    end

    describe ".add" do
      it "adds a definition to all definitions" do
        PageLayout.add({"name" => "foo"})
        expect(PageLayout.all).to include({"name" => "foo"})
      end

      it "adds a array of definitions to all definitions" do
        PageLayout.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(PageLayout.all).to include({"name" => "foo"})
        expect(PageLayout.all).to include({"name" => "bar"})
      end
    end

    describe ".get" do
      it "should return the page_layout definition found by given name" do
        allow(PageLayout).to receive(:all).and_return([{"name" => "default"}, {"name" => "contact"}])
        expect(PageLayout.get("default")).to eq({"name" => "default"})
      end
    end

    describe ".get_all_by_attributes" do
      subject { PageLayout.get_all_by_attributes(unique: true) }

      it "should return all page layout with the given attribute" do
        expect(subject.map { |page_layout| page_layout["name"] }.to_a).to eq(["index", "news", "contact", "erb_layout"])
      end
    end

    describe ".selectable_layouts" do
      let(:site) { create(:alchemy_site) }
      let(:language) { create(:alchemy_language, code: :de) }
      before { language }
      subject { PageLayout.selectable_layouts(language.id) }

      it "should not display hidden page layouts" do
        subject.each { |l| expect(l["hide"]).not_to eq(true) }
      end

      context "with already taken layouts" do
        before do
          allow(PageLayout).to receive(:all).and_return([{"unique" => true}])
          allow(Page).to receive(:where).and_return double(pluck: [1])
        end

        it "should not include unique layouts" do
          subject.each { |l| expect(l["unique"]).not_to eq(true) }
        end
      end

      context "with sites layouts present" do
        let(:definition) do
          {"name" => "default_site", "page_layouts" => %w(index)}
        end

        before do
          allow_any_instance_of(Site).to receive(:definition).and_return(definition)
        end

        it "should only return layouts for site" do
          expect(subject.length).to eq(1)
          expect(subject.first["name"]).to eq("index")
        end
      end
    end

    describe ".element_names_for" do
      it "should return all element names for the given pagelayout" do
        allow(PageLayout).to receive(:get).with("default").and_return({"name" => "default", "elements" => ["element_1", "element_2"]})
        expect(PageLayout.element_names_for("default")).to eq(["element_1", "element_2"])
      end

      context "when given page_layout name does not exist" do
        it "should return an empty array" do
          expect(PageLayout.element_names_for("layout_does_not_exist!")).to eq([])
        end
      end

      context "when page_layout definition does not contain the elements key" do
        it "should return an empty array" do
          allow(PageLayout).to receive(:get).with("layout_without_elements_key").and_return({"name" => "layout_without_elements_key"})
          expect(PageLayout.element_names_for("layout_without_elements_key")).to eq([])
        end
      end
    end

    describe ".human_layout_name" do
      let(:layout) { {"name" => "contact"} }
      subject { PageLayout.human_layout_name(layout["name"]) }

      context "with no translation present" do
        it "returns the name capitalized" do
          is_expected.to eq("Contact")
        end
      end

      context "with translation present" do
        before { expect(Alchemy).to receive(:t).and_return("Kontakt") }

        it "returns the translated name" do
          is_expected.to eq("Kontakt")
        end
      end
    end
  end
end
