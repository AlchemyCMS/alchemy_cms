# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Element do
    # to prevent memoization
    before { Element.instance_variable_set("@definitions", nil) }

    # ClassMethods

    describe '.new_from_scratch' do
      it "should initialize an element by name from scratch" do
        el = Element.new_from_scratch(name: 'article')
        expect(el).to be_valid
      end

      it "should raise an error if the given name is not defined in the elements.yml" do
        expect {
          Element.new_from_scratch(name: 'foobar')
        }.to raise_error(ElementDefinitionError)
      end

      it "should take the first part of an given name containing a hash (#)" do
        el = Element.new_from_scratch(name: 'article#header')
        expect(el.name).to eq("article")
      end

      it "should merge given attributes into defined ones" do
        el = Element.new_from_scratch(name: 'article', page_id: 1)
        expect(el.page_id).to eq(1)
      end

      it "should not have forbidden attributes from definition" do
        el = Element.new_from_scratch(name: 'article')
        expect(el.contents).to eq([])
      end
    end

    describe '.copy' do
      subject { Element.copy(element) }

      let(:element) do
        create(:alchemy_element, create_contents_after_create: true, tag_list: 'red, yellow')
      end

      it "should not create contents from scratch" do
        expect(subject.contents.count).to eq(element.contents.count)
      end

      context 'with differences' do
        subject(:copy) { Element.copy(element, {name: 'foobar'}) }

        it "should create a new record with all attributes of source except given differences" do
          expect(copy.name).to eq('foobar')
        end
      end

      it "should make copies of all contents of source" do
        expect(subject.contents).not_to be_empty
        expect(subject.contents.pluck(:id)).not_to eq(element.contents.pluck(:id))
      end

      it "the copy should include source element tags" do
        expect(subject.tag_list).to eq(element.tag_list)
      end

      context 'with nested elements' do
        let(:element) do
          create(:alchemy_element, :with_nestable_elements, {
            create_contents_after_create: true,
            tag_list: 'red, yellow',
            page: create(:alchemy_page)
          })
        end

        before do
          element.nested_elements << create(:alchemy_element, name: 'slide')
        end

        it "should copy nested elements" do
          expect(subject.nested_elements).to_not be_empty
        end

        context 'copy to new page' do
          let(:new_page) { create(:alchemy_page) }

          subject(:new_element) do
            Element.copy(element, {page_id: new_page.id})
          end

          it "should set page id to new page's id" do
            new_element.nested_elements.each do |nested_element|
              expect(nested_element.page_id).to eq(new_page.id)
            end
          end
        end

        context 'copy to new cell' do
          let(:new_cell) { create(:alchemy_cell) }

          subject(:new_element) do
            Element.copy(element, {cell_id: new_cell.id})
          end

          it "should set cell id to new cell's id" do
            new_element.nested_elements.each do |nested_element|
              expect(nested_element.cell_id).to eq(new_cell.id)
            end
          end
        end
      end
    end

    describe '.definitions' do
      it "should allow erb generated elements" do
        expect(Element.definitions.collect { |el| el['name']} ).to include('erb_element')
      end

      context "without existing yml files" do
        before { allow(File).to receive(:exists?).and_return(false) }

        it "should raise an error" do
          expect { Element.definitions }.to raise_error(LoadError)
        end
      end

      context "without any definitions in elements.yml" do
        # Yes, YAML.load returns false if an empty file exists.
        before { allow(YAML).to receive(:load).and_return(false) }

        it "should return an empty array" do
          expect(Element.definitions).to eq([])
        end
      end
    end

    describe '.display_name_for' do
      it "should return the translation for the given name" do
        expect(I18n).to receive(:t).with('subheadline', scope: "element_names", default: 'Subheadline').and_return('Überschrift')
        expect(Element.display_name_for('subheadline')).to eq('Überschrift')
      end

      it "should return the humanized name if no translation found" do
        expect(Element.display_name_for('not_existing_one')).to eq('Not existing one')
      end
    end

    describe '.excluded' do
      it "should return all elements but excluded ones" do
        create(:alchemy_element, name: 'article')
        create(:alchemy_element, name: 'article')
        excluded = create(:alchemy_element, name: 'claim')
        expect(Element.excluded(['claim'])).not_to include(excluded)
      end
    end

    describe '.named' do
      it "should return all elements by name" do
        element_1 = create(:alchemy_element, name: 'article')
        element_2 = create(:alchemy_element, name: 'headline')
        elements = Element.named(['article'])
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe '.not_in_cell' do
      it "should return all elements that are not in a cell" do
        Element.delete_all
        create(:alchemy_element, cell_id: 6)
        create(:alchemy_element, cell_id: nil)
        expect(Element.not_in_cell.size).to eq(1)
      end
    end

    describe '.published' do
      it "should return all public elements" do
        element_1 = create(:alchemy_element, public: true)
        element_2 = create(:alchemy_element, public: false)
        elements = Element.published
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe '.folded' do
      it "returns all folded elements" do
        element_1 = create(:alchemy_element, folded: true)
        element_2 = create(:alchemy_element, folded: false)
        elements = Element.folded
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    describe '.expanded' do
      it "returns all expanded elements" do
        element_1 = create(:alchemy_element, folded: false)
        element_2 = create(:alchemy_element, folded: true)
        elements = Element.expanded
        expect(elements).to include(element_1)
        expect(elements).to_not include(element_2)
      end
    end

    context 'trash' do
      let(:element) { create(:alchemy_element, page_id: 1) }

      describe '.not_trashed' do
        before { element }

        it "should return a collection of not trashed elements" do
          expect(Element.not_trashed.to_a).to eq([element])
        end
      end

      describe ".trashed" do
        before { element.trash! }

        it "should return a collection of trashed elements" do
          expect(Element.trashed.to_a).to eq([element])
        end
      end
    end

    describe '.all_from_clipboard_for_page' do
      let(:element_1) { build_stubbed(:alchemy_element) }
      let(:element_2) { build_stubbed(:alchemy_element, name: 'news') }
      let(:page)      { build_stubbed(:alchemy_page, :public) }
      let(:clipboard) { [{'id' => element_1.id.to_s}, {'id' => element_2.id.to_s}] }

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

    describe '#all_contents_by_type' do
      let(:element) { create(:alchemy_element, create_contents_after_create: true) }
      let(:expected_contents) { element.contents.essence_texts }

      context "with namespaced essence type" do
        subject { element.all_contents_by_type('Alchemy::EssenceText') }
        it { is_expected.not_to be_empty }
        it('should return the correct list of essences') { is_expected.to eq(expected_contents) }
      end

      context "without namespaced essence type" do
        subject { element.all_contents_by_type('EssenceText') }
        it { is_expected.not_to be_empty }
        it('should return the correct list of essences') { is_expected.to eq(expected_contents) }
      end
    end

    describe '#available_page_cell_names' do
      let(:page)    { create(:alchemy_page, :public) }
      let(:element) { create(:alchemy_element, page: page) }

      context "with page having cells defining the correct elements" do
        before do
          allow(Cell).to receive(:definitions).and_return([
            {'name' => 'header', 'elements' => ['article', 'headline']},
            {'name' => 'footer', 'elements' => ['article', 'text']},
            {'name' => 'sidebar', 'elements' => ['teaser']}
          ])
        end

        it "should return a list of all cells from given page this element could be placed in" do
          create(:alchemy_cell, name: 'header', page: page)
          create(:alchemy_cell, name: 'footer', page: page)
          create(:alchemy_cell, name: 'sidebar', page: page)
          expect(element.available_page_cell_names(page)).to include('header')
          expect(element.available_page_cell_names(page)).to include('footer')
        end

        context "but without any cells" do
          it "should return the 'nil cell'" do
            expect(element.available_page_cell_names(page)).to eq(['for_other_elements'])
          end
        end

      end

      context "with page having cells defining the wrong elements" do
        before do
          allow(Cell).to receive(:definitions).and_return([
            {'name' => 'header', 'elements' => ['download', 'headline']},
            {'name' => 'footer', 'elements' => ['contactform', 'text']},
            {'name' => 'sidebar', 'elements' => ['teaser']}
          ])
        end

        it "should return the 'nil cell'" do
          create(:alchemy_cell, name: 'header', page: page)
          create(:alchemy_cell, name: 'footer', page: page)
          create(:alchemy_cell, name: 'sidebar', page: page)
          expect(element.available_page_cell_names(page)).to eq(['for_other_elements'])
        end
      end
    end

    describe '#content_by_type' do
      before(:each) do
        @element = create(:alchemy_element, name: 'headline')
        @content = @element.contents.first
      end

      context "with namespaced essence type" do
        it "should return content by passing a essence type" do
          expect(@element.content_by_type('Alchemy::EssenceText')).to eq(@content)
        end
      end

      context "without namespaced essence type" do
        it "should return content by passing a essence type" do
          expect(@element.content_by_type('EssenceText')).to eq(@content)
        end
      end
    end

    describe '#display_name' do
      let(:element) { Element.new(name: 'article') }

      it "should call .display_name_for" do
        expect(Element).to receive(:display_name_for).with(element.name)
        element.display_name
      end
    end

    describe '#essence_errors' do
      let(:element) { Element.new(name: 'article') }
      let(:content) { Content.new(name: 'headline') }
      let(:essence) { EssenceText.new(body: '') }

      before do
        allow(element).to receive(:contents) { [content] }
        allow(content).to receive(:essence) { essence }
        allow(content).to receive(:essence_validation_failed?) { true }
        allow(essence).to receive(:validation_errors) { 'Cannot be blank' }
      end

      it "returns hash with essence errors" do
        expect(element.essence_errors).to eq({'headline' => 'Cannot be blank'})
      end
    end

    describe '#essence_error_messages' do
      let(:element) { Element.new(name: 'article') }

      it "should return the translation with the translated content label" do
        expect(I18n).to receive(:t)
          .with('content_names.content', default: 'Content')
          .and_return('Content')
        expect(I18n).to receive(:t)
          .with('content', scope: "content_names.article", default: 'Content')
          .and_return('Contenido')
        expect(I18n).to receive(:t)
          .with('article.content.invalid', {
            scope: "content_validations",
            default: [:"fields.content.invalid", :"errors.invalid"],
            field: "Contenido"})
        expect(element).to receive(:essence_errors)
          .and_return({'content' => [:invalid]})

        element.essence_error_messages
      end
    end

    describe '#display_name_with_preview_text' do
      let(:element) { build_stubbed(:alchemy_element, name: 'Foo') }

      it "returns a string with display name and preview text" do
        allow(element).to receive(:preview_text).and_return('Fula')
        expect(element.display_name_with_preview_text).to eq("Foo: Fula")
      end
    end

    describe '#dom_id' do
      let(:element) { build_stubbed(:alchemy_element) }

      it "returns an string from element name and id" do
        expect(element.dom_id).to eq("#{element.name}_#{element.id}")
      end
    end

    describe '#preview_text' do
      let(:element) { build_stubbed(:alchemy_element) }
      let(:content) { mock_model(Content, preview_text: 'Lorem', preview_content?: false) }
      let(:content_2) { mock_model(Content, preview_text: 'Lorem', preview_content?: false) }
      let(:preview_content) { mock_model(Content, preview_text: 'Lorem', preview_content?: true) }

      context "without a content marked as preview" do
        let(:contents) { [content, content_2] }
        before { allow(element).to receive(:contents).and_return(contents) }

        it "returns the preview text of first content found" do
          expect(content).to receive(:preview_text).with(30)
          element.preview_text
        end
      end

      context "with a content marked as preview" do
        let(:contents) { [content, preview_content] }
        before { allow(element).to receive(:contents).and_return(contents) }

        it "should return the preview_text of this content" do
          expect(preview_content).to receive(:preview_text).with(30)
          element.preview_text
        end
      end

      context "without any contents present" do
        before { allow(element).to receive(:contents).and_return([]) }

        it "should return nil" do
          expect(element.preview_text).to be_nil
        end
      end
    end

    context 'previous and next elements.' do
      let!(:page)     { create(:alchemy_page) }
      let!(:element1) { create(:alchemy_element, page: page, name: 'headline') }
      let!(:element2) { create(:alchemy_element, page: page) }
      let!(:element3) { create(:alchemy_element, page: page, name: 'text') }

      describe '#prev' do
        it "should return previous element on same page" do
          expect(element3.prev).to eq(element2)
        end

        context "with name as parameter" do
          it "should return previous of this kind" do
            expect(element3.prev('headline')).to eq(element1)
          end
        end
      end

      describe '#next' do
        it "should return next element on same page" do
          expect(element2.next).to eq(element3)
        end

        context "with name as parameter" do
          it "should return next of this kind" do
            expect(element1.next('text')).to eq(element3)
          end
        end
      end
    end

    context 'retrieving contents, essences and ingredients' do
      let(:element) { create(:alchemy_element, name: 'news', create_contents_after_create: true) }

      it "should return an ingredient by name" do
        expect(element.ingredient('news_headline')).to eq(EssenceText.first.ingredient)
      end

      it "should return the content for rss title" do
        expect(element.content_for_rss_title).to eq(element.contents.find_by_name('news_headline'))
      end

      it "should return the content for rss descdefinitionription" do
        expect(element.content_for_rss_description).to eq(element.contents.find_by_name('body'))
      end

      context 'if no content is defined as rss title' do
        before { expect(element).to receive(:content_definitions).and_return([]) }

        it "should return nil" do
          expect(element.content_for_rss_title).to be_nil
        end
      end

      context 'if no content is defined as rss description' do
        before { expect(element).to receive(:content_definitions).and_return([]) }

        it "should return nil" do
          expect(element.content_for_rss_description).to be_nil
        end
      end
    end

    describe '#update_contents' do
      subject { element.update_contents(params) }

      let(:page)     { build_stubbed(:alchemy_page) }
      let(:element)  { build_stubbed(:alchemy_element, page: page) }
      let(:content1) { double(:content, id: 1) }
      let(:content2) { double(:content, id: 2) }

      before { allow(element).to receive(:contents).and_return([content1]) }

      context "with attributes hash is nil" do
        let(:params) { nil }
        it { is_expected.to be_truthy }
      end

      context "with valid attributes hash" do
        let(:params) { {"#{content1.id}" => {body: 'Title'}} }

        context 'when certain content is not part of the attributes hash (cause it was not filled by the user)' do
          before do
            allow(element).to receive(:contents).and_return([content1, content2])
          end

          it 'does not try to update that content' do
            expect(content1).to receive(:update_essence).with({body: 'Title'}).and_return(true)
            expect(content2).to_not receive(:update_essence)
            subject
          end
        end

        context 'with passing validations' do
          before do
            expect(content1).to receive(:update_essence).with({body: 'Title'}).and_return(true)
          end

          it { is_expected.to be_truthy }

          it "does not add errors" do
            subject
            expect(element.errors).to be_empty
          end
        end

        context 'with failing validations' do
          it "adds error and returns false" do
            expect(content1).to receive(:update_essence).with({body: 'Title'}).and_return(false)
            is_expected.to be_falsey
            expect(element.errors).not_to be_empty
          end
        end
      end
    end

    describe '.after_update' do
      let(:page)    { create(:alchemy_page) }
      let(:element) { create(:alchemy_element, page: page) }
      let(:now)     { Time.now }

      before do
        allow(Time).to receive(:now).and_return(now)
      end

      context 'with touchable pages' do
        let(:locker)  { mock_model('DummyUser') }
        let(:pages)   { [page] }

        before do
          expect(Alchemy.user_class).to receive(:stamper).at_least(:once).and_return(locker.id)
        end

        it "updates page timestamps" do
          expect(element).to receive(:touchable_pages).and_return(pages)
          expect(pages).to receive(:update_all).with({updated_at: now, updater_id: locker.id})
          element.save
        end

        it "updates page userstamps" do
          element.save
          page.reload
          expect(page.updater_id).to eq(locker.id)
        end
      end

      context 'with cell associated' do
        let(:cell) { mock_model('Cell') }

        before do
          expect(element).to receive(:cell).at_least(:once).and_return(cell)
        end

        it "updates timestamp of cell" do
          expect(element.cell).to receive(:touch)
          element.save
        end
      end

      context 'without cell associated' do
        it "does not update timestamp of cell" do
          expect { element.save }.to_not raise_error
        end
      end
    end

    describe '#taggable?' do
      let(:element) { build(:alchemy_element) }

      context "definition has 'taggable' key with true value" do
        it "should return true" do
          expect(element).to receive(:definition).and_return({
            'name' => 'article',
            'taggable' => true
          })
          expect(element.taggable?).to be_truthy
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          expect(element).to receive(:definition).and_return({
            'name' => 'article',
            'taggable' => 'foo'
          })
          expect(element.taggable?).to be_falsey
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          expect(element).to receive(:definition).and_return({
            'name' => 'article'
          })
          expect(element.taggable?).to be_falsey
        end
      end
    end

    describe '#trash!' do
      let(:element)         { create(:alchemy_element, page_id: 1, cell_id: 1) }
      let(:trashed_element) { element.trash! ; element }
      subject               { trashed_element }

      it             { is_expected.not_to be_public }
      it             { is_expected.to be_folded }

      describe '#position' do
        subject { super().position }
        it { is_expected.to be_nil }
      end
      specify        { expect { element.trash! }.to_not change(element, :page_id) }
      specify        { expect { element.trash! }.to_not change(element, :cell_id) }

      context "with already one trashed element on the same page" do
        let(:element_2) { create(:alchemy_element, page_id: 1) }

        before do
          trashed_element
          element_2
        end

        it "it should be possible to trash another" do
          element_2.trash!
          expect(Element.trashed.to_a).to include(trashed_element, element_2)
        end
      end
    end

    describe "#to_partial_path" do
      it "should return a String in the format of 'alchemy/elements/#{name}_view'" do
        expect(Element.new(name: 'mock').to_partial_path).to eq('alchemy/elements/mock_view')
      end
    end

    describe '#cache_key' do
      let(:page) { stub_model(Page, published_at: Time.now - 1.week) }
      let(:element) { stub_model(Element, page: page, updated_at: Time.now) }

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

      context 'with nestable_elements defined' do
        before do
          allow(element).to receive(:definition) do
            {
              'nestable_elements' => %w(news article)
            }
          end
        end

        it 'returns an array containing all available nested element names' do
          is_expected.to eq %w(news article)
        end
      end

      context 'without nestable_elements defined' do
        before do
          allow(element).to receive(:definition) do
            {}
          end
        end

        it 'returns an empty array' do
          is_expected.to eq []
        end
      end
    end

    describe "#nested_elements" do
      subject { element.nested_elements }

      context 'with nestable_elements defined' do
        let(:element) { create(:alchemy_element, :with_nestable_elements) }

        before do
          element.nested_elements << create(:alchemy_element, name: 'slide')
        end

        it 'returns an AR scope containing nested elements' do
          expect(subject.count).to eq(1)
        end
      end
    end

    describe '#richtext_contents_ids' do
      subject { element.richtext_contents_ids }

      let(:element) { create(:alchemy_element, :with_contents, name: 'text') }

      it { is_expected.to eq(element.content_ids) }

      context 'for element with nested elements' do
        let!(:element) do
          create(:alchemy_element, :with_contents, name: 'text')
        end

        let!(:nested_element_1) do
          create(:alchemy_element, :with_contents, {
            name: 'text',
            parent_element: element,
            folded: false
          })
        end

        let!(:nested_element_2) do
          create(:alchemy_element, :with_contents, {
            name: 'text',
            parent_element: nested_element_1,
            folded: false
          })
        end

        let!(:folded_nested_element_3) do
          create(:alchemy_element, :with_contents, {
            name: 'text',
            parent_element: nested_element_1,
            folded: true
          })
        end

        it 'includes all richtext contents from all expanded descendent elements' do
          is_expected.to eq(
            element.content_ids +
            nested_element_1.content_ids +
            nested_element_2.content_ids
          )
        end
      end
    end

    context 'with parent element' do
      let!(:parent_element) { create(:alchemy_element, :with_nestable_elements) }
      let!(:element)        { create(:alchemy_element, name: 'slide', parent_element: parent_element) }

      it "touches parent after update" do
        expect { element.update!(public: false) }.to change(parent_element, :updated_at)
      end
    end
  end
end
