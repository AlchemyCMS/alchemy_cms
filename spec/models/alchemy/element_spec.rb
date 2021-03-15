# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Element do
    it { is_expected.to belong_to(:page_version) }

    # to prevent memoization
    before { ElementDefinition.instance_variable_set("@definitions", nil) }

    # ClassMethods

    describe ".new" do
      it "should initialize an element by name from scratch" do
        el = Element.new(name: "article")
        expect(el).to be_an(Alchemy::Element)
        expect(el.name).to eq("article")
      end

      it "should raise an error if the given name is not defined in the elements.yml" do
        expect {
          Element.new(name: "foobar")
        }.to raise_error(ElementDefinitionError)
      end

      it "should merge given attributes into defined ones" do
        el = Element.new(name: "article", page_version_id: 1)
        expect(el.page_version_id).to eq(1)
      end

      it "should not have forbidden attributes from definition" do
        el = Element.new(name: "article")
        expect(el.contents).to eq([])
      end
    end

    describe ".create" do
      let(:page_version) { build(:alchemy_page_version) }

      subject(:element) do
        described_class.create(page_version: page_version, name: "article", autogenerate_contents: true)
      end

      it "creates contents" do
        expect(element.contents).to match_array([
          an_instance_of(Alchemy::Content),
          an_instance_of(Alchemy::Content),
          an_instance_of(Alchemy::Content),
          an_instance_of(Alchemy::Content),
        ])
      end

      context "if autogenerate_contents set to false" do
        subject(:element) do
          described_class.create(
            page_version: page_version,
            name: "article",
            autogenerate_contents: false,
          )
        end

        it "creates contents" do
          expect(element.contents).to be_empty
        end
      end

      context "if autogenerate is given in definition" do
        subject(:element) do
          described_class.create(page_version: page_version, name: "slider")
        end

        it "creates nested elements" do
          expect(element.nested_elements).to match_array([
            an_instance_of(Alchemy::Element),
          ])
        end

        it "sets parent elements page_version" do
          expect(element.nested_elements.map(&:page_version_id)).to eq([
            element.page_version_id,
          ])
        end

        context "if element name is not a nestable element" do
          subject(:element) do
            described_class.create(
              page_version: page_version,
              name: "slider",
            )
          end

          before do
            expect(Alchemy::ElementDefinition).to receive(:all).at_least(:once) do
              [
                { "name" => "slider", "nestable_elements" => ["foo"], "autogenerate" => ["bar"] },
              ]
            end
          end

          it "logs error warning" do
            expect_any_instance_of(Alchemy::Logger).to \
              receive(:log_warning).with("Element 'bar' not a nestable element for 'slider'. Skipping!")
            element
          end

          it "skips element" do
            expect(element.nested_elements).to be_empty
          end
        end

        context "if autogenerate_nested_elements set to false" do
          subject(:element) do
            described_class.create(
              page_version: page_version,
              name: "slider",
              autogenerate_nested_elements: false,
            )
          end

          it "creates contents" do
            expect(element.contents).to be_empty
          end
        end
      end
    end

    describe ".copy" do
      subject { Element.copy(element) }

      let(:element) do
        create(:alchemy_element, :with_contents, tag_list: "red, yellow")
      end

      it "should not create contents from scratch" do
        expect(subject.contents.count).to eq(element.contents.count)
      end

      context "with differences" do
        let(:new_page_version) { create(:alchemy_page_version) }
        subject(:copy) { Element.copy(element, { page_version_id: new_page_version.id }) }

        it "should create a new record with all attributes of source except given differences" do
          expect(copy.page_version_id).to eq(new_page_version.id)
        end
      end

      it "should make copies of all contents of source" do
        expect(subject.contents).not_to be_empty
        expect(subject.contents.pluck(:id)).not_to eq(element.contents.pluck(:id))
      end

      it "the copy should include source element tags" do
        expect(subject.tag_list).to eq(element.tag_list)
      end

      context "with nested elements" do
        let(:element) do
          create(:alchemy_element, :with_contents, :with_nestable_elements, {
            tag_list: "red, yellow",
            page: create(:alchemy_page),
          })
        end

        before do
          element.nested_elements << create(:alchemy_element, name: "slide")
        end

        it "should copy nested elements" do
          expect(subject.nested_elements).to_not be_empty
        end

        context "copy to new page version" do
          let(:new_page_version) { create(:alchemy_page_version) }

          subject(:new_element) do
            Element.copy(element, { page_version_id: new_page_version.id })
          end

          it "should set page_version id to new page_version's id" do
            new_element.nested_elements.each do |nested_element|
              expect(nested_element.page_version_id).to eq(new_page_version.id)
            end
          end
        end

        context "copy to new page version" do
          let(:public_version) do
            element.page.versions.create!(public_on: Time.current)
          end

          subject(:new_element) do
            Element.copy(element, { page_version_id: public_version.id })
          end

          it "sets page_version id" do
            new_element.nested_elements.each do |nested_element|
              expect(nested_element.page_version_id).to eq(public_version.id)
            end
          end
        end
      end
    end

    describe ".definitions" do
      it "should allow erb generated elements" do
        expect(Element.definitions.collect { |el| el["name"] }).to include("erb_element")
      end

      context "with a YAML file including a symbol" do
        let(:yaml) { "- name: :symbol" }

        before do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(yaml)
        end

        it "returns the definition without error" do
          expect { Element.definitions }.to_not raise_error
        end
      end

      context "with a YAML file including a Date" do
        let(:yaml) { "- default: 2017-12-24" }

        before do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(yaml)
        end

        it "returns the definition without error" do
          expect { Element.definitions }.to_not raise_error
        end
      end

      context "with a YAML file including a Regex" do
        let(:yaml) { "- format: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'" }

        before do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(yaml)
        end

        it "returns the definition without error" do
          expect { Element.definitions }.to_not raise_error
        end
      end

      context "without existing yml files" do
        before { allow(File).to receive(:exist?).and_return(false) }

        it "should raise an error" do
          expect { Element.definitions }.to raise_error(LoadError)
        end
      end

      context "without any definitions in elements.yml" do
        before { expect(YAML).to receive(:safe_load).and_return(false) }

        it "should return an empty array" do
          expect(Element.definitions).to eq([])
        end
      end
    end

    describe ".display_name_for" do
      it "should return the translation for the given name" do
        expect(Alchemy).to receive(:t).with("subheadline", scope: "element_names", default: "Subheadline").and_return("Überschrift")
        expect(Element.display_name_for("subheadline")).to eq("Überschrift")
      end

      it "should return the humanized name if no translation found" do
        expect(Element.display_name_for("not_existing_one")).to eq("Not existing one")
      end
    end

    describe ".excluded" do
      it "should return all elements but excluded ones" do
        create(:alchemy_element, name: "article")
        create(:alchemy_element, name: "article")
        excluded = create(:alchemy_element, name: "claim")
        expect(Element.excluded(["claim"])).not_to include(excluded)
      end
    end

    describe ".named" do
      it "should return all elements by name" do
        element_1 = create(:alchemy_element, name: "article")
        element_2 = create(:alchemy_element, name: "headline")
        elements = Element.named(["article"])
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe ".fixed" do
      let!(:fixed_element) { create(:alchemy_element, :fixed) }
      let!(:element) { create(:alchemy_element) }

      it "should return all elements that are fixed" do
        expect(Element.fixed).to match_array([
          fixed_element,
        ])
      end
    end

    describe ".unfixed" do
      let!(:fixed_element) { create(:alchemy_element, :fixed) }
      let!(:element) { create(:alchemy_element) }

      it "should return all elements that are not fixed" do
        expect(Element.unfixed).to match_array([
          element,
        ])
      end
    end

    describe ".published" do
      it "should return all public elements" do
        element_1 = create(:alchemy_element, public: true)
        element_2 = create(:alchemy_element, public: false)
        elements = Element.published
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe ".folded" do
      it "returns all folded elements" do
        element_1 = create(:alchemy_element, folded: true)
        element_2 = create(:alchemy_element, folded: false)
        elements = Element.folded
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe ".expanded" do
      it "returns all expanded elements" do
        element_1 = create(:alchemy_element, folded: false)
        element_2 = create(:alchemy_element, folded: true)
        elements = Element.expanded
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe ".not_nested" do
      subject { Element.not_nested }

      let!(:element_1) { create(:alchemy_element) }
      let!(:element_2) { create(:alchemy_element, :nested) }

      it "returns all not nested elements" do
        is_expected.to match_array([element_1, element_2.parent_element])
      end
    end

    describe ".all_from_clipboard_for_page" do
      let(:element_1) { create(:alchemy_element, page_version: page.draft_version) }
      let(:element_2) { create(:alchemy_element, name: "news", page_version: page.draft_version) }
      let(:page) { create(:alchemy_page, :public) }
      let(:clipboard) { [{ "id" => element_1.id.to_s }, { "id" => element_2.id.to_s }] }

      before do
        allow(Element).to receive(:all_from_clipboard).and_return([element_1, element_2])
      end

      it "return all elements from clipboard that could be placed on page" do
        elements = Element.all_from_clipboard_for_page(clipboard, page)
        expect(elements).to eq([element_1])
        expect(elements).not_to eq([element_2])
      end

      context "page nil" do
        it "returns empty array" do
          expect(Element.all_from_clipboard_for_page(clipboard, nil)).to eq([])
        end
      end

      context "clipboard nil" do
        it "returns empty array" do
          expect(Element.all_from_clipboard_for_page(nil, page)).to eq([])
        end
      end
    end

    # InstanceMethods

    describe "#all_contents_by_type" do
      let(:element) { create(:alchemy_element, :with_contents) }
      let(:expected_contents) { element.contents.essence_texts }

      context "with namespaced essence type" do
        subject { element.all_contents_by_type("Alchemy::EssenceText") }
        it { is_expected.not_to be_empty }
        it("should return the correct list of essences") { is_expected.to eq(expected_contents) }
      end

      context "without namespaced essence type" do
        subject { element.all_contents_by_type("EssenceText") }
        it { is_expected.not_to be_empty }
        it("should return the correct list of essences") { is_expected.to eq(expected_contents) }
      end
    end

    describe "#content_by_type" do
      before(:each) do
        @element = create(:alchemy_element, name: "headline")
        @content = @element.contents.first
      end

      context "with namespaced essence type" do
        it "should return content by passing a essence type" do
          expect(@element.content_by_type("Alchemy::EssenceText")).to eq(@content)
        end
      end

      context "without namespaced essence type" do
        it "should return content by passing a essence type" do
          expect(@element.content_by_type("EssenceText")).to eq(@content)
        end
      end
    end

    describe "#display_name" do
      let(:element) { Element.new(name: "article") }

      it "should call .display_name_for" do
        expect(Element).to receive(:display_name_for).with(element.name)
        element.display_name
      end
    end

    describe "#essence_errors" do
      let(:element) { Element.new(name: "article") }
      let(:content) { Content.new(name: "headline") }
      let(:essence) { EssenceText.new(body: "") }

      before do
        allow(element).to receive(:contents) { [content] }
        allow(content).to receive(:essence) { essence }
        allow(content).to receive(:essence_validation_failed?) { true }
        allow(essence).to receive(:validation_errors) { "Cannot be blank" }
      end

      it "returns hash with essence errors" do
        expect(element.essence_errors).to eq({ "headline" => "Cannot be blank" })
      end
    end

    describe "#essence_error_messages" do
      let(:element) { Element.new(name: "article") }

      it "should return the translation with the translated content label" do
        expect(Alchemy).to receive(:t)
                             .with("content_names.content", default: "Content")
                             .and_return("Content")
        expect(Alchemy).to receive(:t)
                             .with("content", scope: "content_names.article", default: "Content")
                             .and_return("Contenido")
        expect(Alchemy).to receive(:t)
                             .with("article.content.invalid", {
                               scope: "content_validations",
                               default: [:"fields.content.invalid", :"errors.invalid"],
                               field: "Contenido",
                             })
        expect(element).to receive(:essence_errors)
                             .and_return({ "content" => [:invalid] })

        element.essence_error_messages
      end
    end

    describe "#display_name_with_preview_text" do
      let(:element) { build_stubbed(:alchemy_element, name: "Foo") }

      it "returns a string with display name and preview text" do
        allow(element).to receive(:preview_text).and_return("Fula")
        expect(element.display_name_with_preview_text).to eq("Foo: Fula")
      end
    end

    describe "#dom_id" do
      let(:element) { build_stubbed(:alchemy_element) }

      it "returns an string from element name and id" do
        expect(element.dom_id).to eq("#{element.name}_#{element.id}")
      end
    end

    describe "#preview_text" do
      let(:element) { build_stubbed(:alchemy_element) }

      let(:content) do
        mock_model(Content, preview_text: "Content 1", preview_content?: false)
      end

      let(:content_2) do
        mock_model(Content, preview_text: "Content 2", preview_content?: false)
      end

      let(:contents) { [] }

      let(:preview_content) do
        mock_model(Content, preview_text: "Preview Content", preview_content?: true)
      end

      before do
        allow(element).to receive(:contents).and_return(contents)
      end

      context "without a content marked as preview" do
        let(:contents) { [content, content_2] }

        it "returns the preview text of first content found" do
          expect(content).to receive(:preview_text).with(60)
          element.preview_text
        end
      end

      context "with a content marked as preview" do
        let(:contents) { [content, preview_content] }

        it "should return the preview_text of this content" do
          expect(preview_content).to receive(:preview_text).with(60)
          element.preview_text
        end
      end

      context "without any contents present" do
        it "should return nil" do
          expect(element.preview_text).to be_nil
        end
      end

      context "with nested elements" do
        let(:element) do
          build_stubbed(:alchemy_element, :with_nestable_elements)
        end

        let(:nested_element) do
          build_stubbed(:alchemy_element, name: "slide")
        end

        before do
          allow(nested_element).to receive(:contents) { [content_2] }
          allow(element).to receive(:all_nested_elements) { [nested_element] }
        end

        context "when parent element has contents" do
          before do
            allow(element).to receive(:contents) { [content] }
          end

          it "returns the preview text from the parent element" do
            expect(content).to receive(:preview_text)
            expect(element.preview_text)
          end
        end

        context "when parent element has no contents but nestable element has" do
          before do
            allow(element).to receive(:contents) { [] }
            allow(nested_element).to receive(:contents) { [content_2] }
          end

          it "returns the preview text from the first nested element" do
            expect(content_2).to receive(:preview_text)
            expect(element.preview_text)
          end
        end
      end
    end

    describe "previous and next elements." do
      let(:page) { create(:alchemy_page, :public, :language_root) }

      before(:each) do
        @element1 = create(:alchemy_element, page: page, page_version: page.public_version, name: "headline")
        @element2 = create(:alchemy_element, page: page, page_version: page.public_version)
        @element3 = create(:alchemy_element, page: page, page_version: page.public_version, name: "text")
      end

      describe "#prev" do
        it "should return previous element on same page version" do
          expect(@element3.prev).to eq(@element2)
        end

        context "with name as parameter" do
          it "should return previous of this kind" do
            expect(@element3.prev("headline")).to eq(@element1)
          end
        end
      end

      describe "#next" do
        it "should return next element on same page version" do
          expect(@element2.next).to eq(@element3)
        end

        context "with name as parameter" do
          it "should return next of this kind" do
            expect(@element1.next("text")).to eq(@element3)
          end
        end
      end
    end

    context "retrieving contents, essences and ingredients" do
      let(:element) { create(:alchemy_element, :with_contents, name: "news") }

      it "should return an ingredient by name" do
        expect(element.ingredient("news_headline")).to eq(EssenceText.first.ingredient)
      end

      it "should return the content for rss title" do
        expect(element.content_for_rss_title).to eq(element.contents.find_by_name("news_headline"))
      end

      it "should return the content for rss descdefinitionription" do
        expect(element.content_for_rss_description).to eq(element.contents.find_by_name("body"))
      end

      context "if no content is defined as rss title" do
        before { expect(element).to receive(:content_definitions).and_return([]) }

        it "should return nil" do
          expect(element.content_for_rss_title).to be_nil
        end
      end

      context "if no content is defined as rss description" do
        before { expect(element).to receive(:content_definitions).and_return([]) }

        it "should return nil" do
          expect(element.content_for_rss_description).to be_nil
        end
      end
    end

    describe "#update_contents" do
      subject { element.update_contents(params) }

      let(:element) { build_stubbed(:alchemy_element) }
      let(:content1) { double(:content, id: 1) }
      let(:content2) { double(:content, id: 2) }

      before { allow(element).to receive(:contents).and_return([content1]) }

      context "with attributes hash is nil" do
        let(:params) { nil }
        it { is_expected.to be_truthy }
      end

      context "with valid attributes hash" do
        let(:params) { { content1.id.to_s => { body: "Title" } } }

        context "when certain content is not part of the attributes hash (cause it was not filled by the user)" do
          before do
            allow(element).to receive(:contents).and_return([content1, content2])
          end

          it "does not try to update that content" do
            expect(content1).to receive(:update_essence).with({ body: "Title" }).and_return(true)
            expect(content2).to_not receive(:update_essence)
            subject
          end
        end

        context "with passing validations" do
          before do
            expect(content1).to receive(:update_essence).with({ body: "Title" }).and_return(true)
          end

          it { is_expected.to be_truthy }

          it "does not add errors" do
            subject
            expect(element.errors).to be_empty
          end
        end

        context "with failing validations" do
          it "adds error and returns false" do
            expect(content1).to receive(:update_essence).with({ body: "Title" }).and_return(false)
            is_expected.to be_falsey
            expect(element.errors).not_to be_empty
          end
        end
      end
    end

    describe ".after_update" do
      let(:element) { create(:alchemy_element, page_version: page_version) }

      let(:page_version) do
        create(:alchemy_page_version).tap do |page_version|
          page_version.update_column(:updated_at, 3.hours.ago)
        end
      end

      it "touches the page_version" do
        expect { element.save }.to change { page_version.updated_at }
      end

      context "with touchable pages" do
        let(:touchable_page) do
          create(:alchemy_page).tap do |page|
            page.update_column(:updated_at, 3.hours.ago)
          end
        end

        it "updates their timestamps" do
          expect(element).to receive(:touchable_pages) { [touchable_page] }
          expect { element.save }.to change { touchable_page.updated_at }
        end
      end
    end

    describe "#taggable?" do
      let(:element) { build(:alchemy_element) }

      context "definition has 'taggable' key with true value" do
        it "should return true" do
          expect(element).to receive(:definition).and_return({
            "name" => "article",
            "taggable" => true,
          })
          expect(element.taggable?).to be_truthy
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          expect(element).to receive(:definition).and_return({
            "name" => "article",
            "taggable" => "foo",
          })
          expect(element.taggable?).to be_falsey
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          expect(element).to receive(:definition).and_return({
            "name" => "article",
          })
          expect(element.taggable?).to be_falsey
        end
      end
    end

    describe "#compact?" do
      subject { element.compact? }

      let(:element) { build(:alchemy_element) }

      before do
        expect(element).to receive(:definition) { definition }
      end

      context "definition has 'compact' key with true value" do
        let(:definition) { { "compact" => true } }
        it { is_expected.to be(true) }
      end

      context "definition has 'compact' key with foo value" do
        let(:definition) { { "compact" => "foo" } }
        it { is_expected.to be(false) }
      end

      context "definition has no 'compact' key" do
        let(:definition) { { "name" => "article" } }
        it { is_expected.to be(false) }
      end
    end

    describe "#deprecated?" do
      subject { element.deprecated? }

      let(:element) { build(:alchemy_element) }

      before do
        expect(element).to receive(:definition) { definition }
      end

      context "definition has 'deprecated' key with true value" do
        let(:definition) { { "deprecated" => true } }
        it { is_expected.to be(true) }
      end

      context "definition has 'deprecated' key with foo value" do
        let(:definition) { { "deprecated" => "This is deprecated" } }
        it { is_expected.to be(true) }
      end

      context "definition has no 'deprecated' key" do
        let(:definition) { { "name" => "article" } }
        it { is_expected.to be(false) }
      end
    end

    describe "#to_partial_path" do
      it do
        expect(Element.new(name: "article").to_partial_path).to eq("alchemy/elements/article")
      end
    end

    describe "#cache_key" do
      let(:page) { create(:alchemy_page, published_at: Time.current - 1.week) }
      let(:element) { create(:alchemy_element, page_version: page.draft_version, updated_at: Time.current) }

      subject { element.cache_key }

      before do
        expect(Page).to receive(:current_preview).and_return(preview)
      end

      context "when current page rendered in preview mode" do
        let(:preview) { page }

        it { is_expected.to eq("alchemy/elements/#{element.id}-#{element.updated_at}") }
      end

      context "when current page not in preview mode" do
        let(:preview) { nil }

        it { is_expected.to eq("alchemy/elements/#{element.id}-#{page.published_at}") }
      end
    end

    it_behaves_like "having a hint" do
      let(:subject) { Element.new }
    end

    describe "#nestable_elements" do
      let(:element) { Element.new }

      subject { element.nestable_elements }

      context "with nestable_elements defined" do
        before do
          allow(element).to receive(:definition) do
            {
              "nestable_elements" => %w(news article),
            }
          end
        end

        it "returns an array containing all available nested element names" do
          is_expected.to eq %w(news article)
        end
      end

      context "without nestable_elements defined" do
        before do
          allow(element).to receive(:definition) do
            {}
          end
        end

        it "returns an empty array" do
          is_expected.to eq []
        end
      end
    end

    describe "#all_nested_elements" do
      subject { element.all_nested_elements }

      let!(:page) { create(:alchemy_page) }
      let!(:element) { create(:alchemy_element, page: page) }
      let!(:nested_element) { create(:alchemy_element, parent_element: element, page: page) }

      it "returns nested elements" do
        expect(subject).to eq([nested_element])
      end

      context "with hidden nested elements" do
        let!(:hidden_nested_element) do
          create(:alchemy_element, parent_element: element, page: page, public: false)
        end

        it "includes them" do
          expect(subject).to include(hidden_nested_element)
        end
      end
    end

    describe "#nested_elements" do
      subject { element.nested_elements }

      context "with nestable_elements defined" do
        let!(:page) { create(:alchemy_page) }
        let!(:element) { create(:alchemy_element, page: page) }
        let!(:nested_element) { create(:alchemy_element, parent_element: element, page: page) }

        it "returns nested elements" do
          expect(subject).to eq([nested_element])
        end

        context "with hidden nested elements" do
          let!(:hidden_nested_element) do
            create(:alchemy_element, parent_element: element, page: page, public: false)
          end

          it "does not include them" do
            expect(subject).to eq([nested_element])
          end
        end
      end
    end

    describe "#richtext_contents_ids" do
      subject { element.richtext_contents_ids }

      let(:element) { create(:alchemy_element, :with_contents, name: "text") }

      it { is_expected.to eq(element.content_ids) }

      context "for element with nested elements" do
        let!(:element) do
          create(:alchemy_element, :with_contents, name: "text")
        end

        let!(:nested_element_1) do
          create(:alchemy_element, :with_contents, {
            name: "text",
            parent_element: element,
            folded: false,
          })
        end

        let!(:nested_element_2) do
          create(:alchemy_element, :with_contents, {
            name: "text",
            parent_element: nested_element_1,
            folded: false,
          })
        end

        let!(:folded_nested_element_3) do
          create(:alchemy_element, :with_contents, {
            name: "text",
            parent_element: nested_element_1,
            folded: true,
          })
        end

        it "includes all richtext contents from all expanded descendent elements" do
          is_expected.to eq(
            element.content_ids +
            nested_element_1.content_ids +
            nested_element_2.content_ids,
          )
        end
      end
    end

    context "with parent element" do
      let!(:parent_element) { create(:alchemy_element, :with_nestable_elements) }
      let!(:element) { create(:alchemy_element, name: "slide", parent_element: parent_element) }

      it "touches parent after update" do
        parent_element.update_column(:updated_at, 3.days.ago)
        expect { element.update!(public: false) }.to change(parent_element, :updated_at)
      end
    end
  end
end
