# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Content do
    let(:element) { create(:alchemy_element, :with_contents, name: "headline") }
    let(:content) { element.contents.find_by(essence_type: "Alchemy::EssenceText") }

    it "should return the ingredient from its essence" do
      content.essence.update_columns(body: "Hello")
      expect(content.ingredient).to eq("Hello")
    end

    describe ".normalize_essence_type" do
      context "passing namespaced essence type" do
        it "should not add alchemy namespace" do
          expect(Content.normalize_essence_type("Alchemy::EssenceText")).to eq("Alchemy::EssenceText")
        end
      end

      context "passing not namespaced essence type" do
        it "should add alchemy namespace" do
          expect(Content.normalize_essence_type("EssenceText")).to eq("Alchemy::EssenceText")
        end
      end

      context "passing non-namespaced essence type for an existing non-namespaced essence" do
        it "should not add alchemy namespace" do
          expect(Content.normalize_essence_type("DummyModel")).to eq("DummyModel")
        end
      end
    end

    describe "#normalized_essence_type" do
      context "without namespace in essence_type column" do
        it "should return the namespaced essence type" do
          expect(Content.new(essence_type: "EssenceText").normalized_essence_type).to eq("Alchemy::EssenceText")
        end
      end

      context "with namespace in essence_type column" do
        it "should return the namespaced essence type" do
          expect(Content.new(essence_type: "Alchemy::EssenceText").normalized_essence_type).to eq("Alchemy::EssenceText")
        end
      end
    end

    describe "#update_essence" do
      subject { content.update_essence(params) }

      let(:element) { create(:alchemy_element, :with_contents, name: "text") }
      let(:content) { element.contents.first }
      let(:params) { {} }

      context "with params given" do
        let(:params) { { body: "Mikes Petshop" } }
        let(:essence) { content.essence }

        before do
          expect(essence).to receive(:content).at_least(:once).and_return content
        end

        it "updates the attributes of related essence and return true" do
          is_expected.to be_truthy
          expect(content.ingredient).to eq("Mikes Petshop")
        end
      end

      context "with validations and without params given" do
        let(:element) { create(:alchemy_element, :with_contents, name: "contactform") }

        it "should add error messages if save fails and return false" do
          is_expected.to be_falsey
          expect(content.errors[:essence].size).to eq(1)
        end
      end

      context "if essence is missing" do
        before do
          expect(content).to receive(:essence).and_return nil
        end

        it "should raise error" do
          expect { subject }.to raise_error(EssenceMissingError)
        end
      end
    end

    describe ".copy" do
      let(:element) do
        create(:alchemy_element, :with_contents, name: "text")
      end

      let(:new_element) do
        create(:alchemy_element, name: "text")
      end

      let(:content) do
        element.contents.first
      end

      it "should create a new record with all attributes of source except given differences" do
        copy = Content.copy(content, { element_id: new_element.id })
        expect(copy.element_id).to eq(new_element.id)
      end

      it "should make a new record for essence of source" do
        copy = Content.copy(content)
        expect(copy.essence_id).not_to eq(content.essence_id)
      end

      it "should copy source essence attributes" do
        content.essence.update_column(:body, "Lorem ipsum")
        copy = Content.copy(content)
        copy.essence.body == content.essence.body
      end
    end

    describe ".definitions" do
      context "without any definitions in elements.yml file" do
        before { expect(Element).to receive(:definitions).and_return([]) }

        it "should return an empty array" do
          expect(Content.definitions).to eq([])
        end
      end

      context "with some element definitions having no contents defined" do
        before do
          expect(Element).to receive(:definitions) do
            [
              {
                "name" => "foo",
                "contents" => [{ "name" => "title" }],
              },
              {
                "name" => "bar",
              },
            ]
          end
        end

        it "returns only content definitions" do
          expect(Content.definitions).to match_array(
            [{ "name" => "title" }],
          )
        end
      end
    end

    describe ".new" do
      let(:element) { build(:alchemy_element) }

      subject { Content.new({ element: element, name: "headline" }) }

      it "builds a new content instance from elements.yml definition" do
        is_expected.to be_instance_of(Content)
        is_expected.to_not be_persisted
      end

      it "builds a new essence instance from elements.yml definition" do
        expect(subject.essence).to be_instance_of(EssenceText)
        expect(subject.essence).to_not be_persisted
      end
    end

    describe ".create" do
      let(:element) { create(:alchemy_element, name: "article") }

      subject(:content) { Content.create(element: element, name: "headline") }

      it "creates the content" do
        is_expected.to be_instance_of(Alchemy::Content)
        is_expected.to be_persisted
      end

      it "creates the essence" do
        expect(subject.essence).to be_instance_of(Alchemy::EssenceText)
        expect(subject.essence).to be_persisted
      end

      context "with default value present" do
        it "should have the ingredient column filled with default value." do
          allow_any_instance_of(Content).to receive(:definition) do
            {
              "name" => "headline",
              "type" => "EssenceText",
              "default" => "Welcome",
            }.with_indifferent_access
          end
          expect(content.ingredient).to eq("Welcome")
        end

        context "with default value being a symbol" do
          it "passes default value through I18n." do
            allow_any_instance_of(Content).to receive(:definition) do
              {
                "name" => "headline",
                "type" => "EssenceText",
                "default" => :welcome,
              }.with_indifferent_access
            end
            expect(content.ingredient).to eq("Welcome to my site")
          end
        end
      end
    end

    describe "#ingredient=" do
      let(:element) { create(:alchemy_element, name: "headline") }

      it "should set the given value to the ingredient column of essence" do
        c = Content.create(element: element, name: "headline")
        c.ingredient = "Welcome"
        expect(c.ingredient).to eq("Welcome")
      end

      context "no essence associated" do
        let(:element) { create(:alchemy_element, name: "headline") }
        let(:content) { Alchemy::Content.new(element: element, name: "headline").tap(&:save) }

        before do
          expect(content).to receive(:essence) { nil }
        end

        it "should raise error" do
          expect { content.ingredient = "Welcome" }.to raise_error(EssenceMissingError)
        end
      end
    end

    describe "#dom_id" do
      let(:content) { build_stubbed(:alchemy_content) }

      it "returns a dom id string" do
        expect(content.dom_id).to eq("essence_text_#{content.id}")
      end

      context "without an essence" do
        before { expect(content).to receive(:essence).and_return nil }

        it "returns empty string" do
          expect(content.dom_id).to eq("")
        end
      end
    end

    describe "#essence_partial_name" do
      let(:content) { build_stubbed(:alchemy_content) }

      it "returns the essence#partial_name" do
        expect(content.essence).to receive(:partial_name)
        content.essence_partial_name
      end

      context "without an essence" do
        before { expect(content).to receive(:essence).and_return nil }

        it "returns empty string" do
          expect(content.essence_partial_name).to eq("")
        end
      end
    end

    describe "#deprecated?" do
      let(:content) { build_stubbed(:alchemy_content) }

      subject { content.deprecated? }

      context "not defined as deprecated" do
        it "returns false" do
          expect(content.deprecated?).to be false
        end
      end

      context "defined as deprecated" do
        before do
          expect(content).to receive(:definition).at_least(:once).and_return({
            "deprecated" => true,
          })
        end

        it "returns true" do
          expect(content.deprecated?).to be true
        end
      end

      context "defined as deprecated per String" do
        before do
          expect(content).to receive(:definition).at_least(:once).and_return({
            "deprecated" => "This content is deprecated",
          })
        end

        it "returns true" do
          expect(content.deprecated?).to be true
        end
      end
    end

    describe "#preview_content?" do
      let(:content) { build_stubbed(:alchemy_content) }

      context "not defined as preview content" do
        it "returns false" do
          expect(content.preview_content?).to be false
        end
      end

      context "defined as preview content" do
        before do
          expect(content).to receive(:definition).at_least(:once).and_return({
            "as_element_title" => true,
          })
        end

        it "returns true" do
          expect(content.preview_content?).to be true
        end
      end
    end

    describe "#preview_text" do
      let(:essence) { mock_model(EssenceText, preview_text: "Lorem") }
      let(:content) { c = Content.new; c.essence = essence; c }

      it "should return the essences preview_text" do
        expect(essence).to receive(:preview_text).with(30)
        content.preview_text
      end
    end

    describe "#has_tinymce?" do
      let(:element) { build_stubbed(:alchemy_element, name: "article") }
      let(:content) { build_stubbed(:alchemy_content, name: "text", element: element) }

      subject { content.has_tinymce? }

      it { is_expected.to eq(false) }

      context "having custom tinymce config hash" do
        before do
          expect(content).to receive(:settings) do
            { tinymce: { toolbar: [] } }
          end
        end

        it { is_expected.to eq(true) }
      end

      context "having essence that has_tinymce? eq true" do
        before do
          expect(content.essence).to receive(:has_tinymce?) { true }
        end

        it { is_expected.to eq(true) }
      end

      context "having nil essence" do
        before do
          content.essence = nil
        end

        it { is_expected.to eq(false) }
      end
    end

    describe "#has_custom_tinymce_config?" do
      let(:element) { build_stubbed(:alchemy_element, name: "article") }
      let(:content) { build_stubbed(:alchemy_content, name: "text", element: element) }

      subject { content.has_custom_tinymce_config? }

      it { is_expected.to eq(false) }

      context "having custom tinymce config hash" do
        before do
          expect(content).to receive(:settings) do
            { tinymce: { toolbar: [] } }
          end
        end

        it { is_expected.to eq(true) }
      end
    end

    describe "#tinymce_class_name" do
      let(:element) { build_stubbed(:alchemy_element, name: "article") }
      let(:content) { build_stubbed(:alchemy_content, name: "text", element: element) }

      subject { content.tinymce_class_name }

      it { is_expected.to eq("has_tinymce") }

      context "having custom tinymce config" do
        before do
          expect(content).to receive(:has_custom_tinymce_config?).and_return(true)
        end

        it "returns name including element name" do
          is_expected.to eq("has_tinymce article_text")
        end
      end
    end

    it_behaves_like "having a hint" do
      let(:subject) { Content.new }
    end

    describe "#settings" do
      let(:element) { build_stubbed(:alchemy_element, name: "article") }
      let(:content) { build_stubbed(:alchemy_content, name: "headline", element: element) }

      it "returns the settings hash from definition" do
        expect(content.settings).to eq({ "linkable" => true })
      end

      context "if settings are not defined" do
        let(:content) { build_stubbed(:alchemy_content, name: "intro", element: element) }

        it "returns empty hash" do
          expect(content.settings).to eq({})
        end
      end
    end

    describe "#settings_value" do
      let(:key) { :key }
      let(:settings) { Hash.new }

      subject { content.settings_value(key, options) }

      before do
        allow(content).to receive(:settings) { settings }
      end

      context "with content having settings" do
        let(:settings) { { key: "settings_value" } }

        context "and empty options" do
          let(:options) { {} }

          it "returns the value for key from content settings" do
            expect(subject).to eq("settings_value")
          end
        end

        context "and nil options" do
          let(:options) { nil }

          it "returns the value for key from content settings" do
            expect(subject).to eq("settings_value")
          end
        end

        context "but same key present in options" do
          let(:options) { { key: "options_value" } }

          it "returns the value for key from options" do
            expect(subject).to eq("options_value")
          end
        end
      end

      context "with content having no settings" do
        let(:settings) { {} }

        context "and empty options" do
          let(:options) { {} }

          it { expect(subject).to eq(nil) }
        end

        context "but key present in options" do
          let(:options) { { key: "options_value" } }

          it "returns the value for key from options" do
            expect(subject).to eq("options_value")
          end
        end
      end

      context "with content having settings with string as key" do
        let(:settings) { { "key" => "value_from_string_key" } }
        let(:options) { {} }

        it "returns value" do
          expect(subject).to eq("value_from_string_key")
        end
      end

      context "with key passed as string" do
        let(:settings) { { key: "value_from_symbol_key" } }
        let(:key) { "key" }
        let(:options) { {} }

        it "returns value" do
          expect(subject).to eq("value_from_symbol_key")
        end
      end
    end

    context "delegations" do
      let(:page) { create(:alchemy_page, :restricted) }

      it "delegates restricted? to page" do
        element.update!(page: page)
        expect(page.restricted?).to be true
        expect(content.page).to eq page
        expect(content.restricted?).to be true
      end

      it "delegates public? to element" do
        element.update!(public: false)
        expect(element.public?).to be false
        expect(content.public?).to be false
      end
    end
  end
end
