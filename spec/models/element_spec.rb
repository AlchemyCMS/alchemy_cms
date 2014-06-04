# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Element do
    # to prevent memoization
    before { Element.instance_variable_set("@definitions", nil) }

    # ClassMethods

    describe '.copy' do
      let(:element) { FactoryGirl.create(:element, :create_contents_after_create => true, :tag_list => 'red, yellow') }

      it "should not create contents from scratch" do
        copy = Element.copy(element)
        copy.contents.count.should == element.contents.count
      end

      it "should create a new record with all attributes of source except given differences" do
        copy = Element.copy(element, {:name => 'foobar'})
        copy.name.should == 'foobar'
      end

      it "should make copies of all contents of source" do
        copy = Element.copy(element)
        copy.contents.pluck(:id).should_not == element.contents.pluck(:id)
      end

      it "the copy should include source element tags" do
        copy = Element.copy(element)
        copy.tag_list.should == element.tag_list
      end
    end

    describe '.definitions' do
      context "without existing yml files" do
        before { File.stub(:exists?).and_return(false) }

        it "should raise an error" do
          expect { Element.definitions }.to raise_error(LoadError)
        end
      end

      context "without any definitions in elements.yml" do
        before { YAML.stub(:load_file).and_return(false) } # Yes, YAML.load_file returns false if an empty file exists.

        it "should return an empty array" do
          Element.definitions.should == []
        end
      end
    end

    describe '.display_name_for' do
      it "should return the translation for the given name" do
        I18n.should_receive(:t).with('subheadline', scope: "element_names", default: 'Subheadline').and_return('Überschrift')
        expect(Element.display_name_for('subheadline')).to eq('Überschrift')
      end

      it "should return the humanized name if no translation found" do
        expect(Element.display_name_for('not_existing_one')).to eq('Not existing one')
      end
    end

    describe '.excluded' do
      it "should return all elements but excluded ones" do
        FactoryGirl.create(:element, :name => 'article')
        FactoryGirl.create(:element, :name => 'article')
        excluded = FactoryGirl.create(:element, :name => 'claim')
        Element.excluded(['claim']).should_not include(excluded)
      end
    end

    describe '.named' do
      it "should return all elements by name" do
        element_1 = FactoryGirl.create(:element, :name => 'article')
        element_2 = FactoryGirl.create(:element, :name => 'article')
        elements = Element.named(['article'])
        elements.should include(element_1)
        elements.should include(element_2)
      end
    end

    describe '.not_in_cell' do
      it "should return all elements that are not in a cell" do
        Element.delete_all
        FactoryGirl.create(:element, :cell_id => 6)
        FactoryGirl.create(:element, :cell_id => nil)
        Element.not_in_cell.should have(1).element
      end
    end

    describe '.published' do
      it "should return all public elements" do
        element_1 = FactoryGirl.create(:element, :public => true)
        element_2 = FactoryGirl.create(:element, :public => true)
        elements = Element.published
        elements.should include(element_1)
        elements.should include(element_2)
      end
    end

    context 'trash' do
      let(:element) { FactoryGirl.create(:element, page_id: 1) }

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
      let(:element_1) { FactoryGirl.build_stubbed(:element) }
      let(:element_2) { FactoryGirl.build_stubbed(:element, name: 'news') }
      let(:page)      { FactoryGirl.build_stubbed(:public_page) }
      let(:clipboard) { [{'id' => element_1.id.to_s}, {'id' => element_2.id.to_s}] }

      before do
        Element.stub(:all_from_clipboard).and_return([element_1, element_2])
      end

      it "return all elements from clipboard that could be placed on page" do
        elements = Element.all_from_clipboard_for_page(clipboard, page)
        elements.should == [element_1]
        elements.should_not == [element_2]
      end

      context "page nil" do
        it "returns empty array" do
          Element.all_from_clipboard_for_page(clipboard, nil).should == []
        end
      end

      context "clipboard nil" do
        it "returns empty array" do
          Element.all_from_clipboard_for_page(nil, page).should == []
        end
      end
    end

    # InstanceMethods

    describe '#all_contents_by_type' do
      let(:element) { FactoryGirl.create(:element, create_contents_after_create: true) }
      let(:expected_contents) { element.contents.essence_texts }

      context "with namespaced essence type" do
        subject { element.all_contents_by_type('Alchemy::EssenceText') }
        it { should_not be_empty }
        it('should return the correct list of essences') { should == expected_contents }
      end

      context "without namespaced essence type" do
        subject { element.all_contents_by_type('EssenceText') }
        it { should_not be_empty }
        it('should return the correct list of essences') { should == expected_contents }
      end
    end

    describe '#available_page_cell_names' do
      let(:page)    { FactoryGirl.create(:public_page) }
      let(:element) { FactoryGirl.create(:element, page: page) }

      context "with page having cells defining the correct elements" do
        before do
          Cell.stub(:definitions).and_return([
            {'name' => 'header', 'elements' => ['article', 'headline']},
            {'name' => 'footer', 'elements' => ['article', 'text']},
            {'name' => 'sidebar', 'elements' => ['teaser']}
          ])
        end

        it "should return a list of all cells from given page this element could be placed in" do
          FactoryGirl.create(:cell, name: 'header', page: page)
          FactoryGirl.create(:cell, name: 'footer', page: page)
          FactoryGirl.create(:cell, name: 'sidebar', page: page)
          element.available_page_cell_names(page).should include('header')
          element.available_page_cell_names(page).should include('footer')
        end

        context "but without any cells" do
          it "should return the 'nil cell'" do
            element.available_page_cell_names(page).should == ['for_other_elements']
          end
        end

      end

      context "with page having cells defining the wrong elements" do
        before do
          Cell.stub(:definitions).and_return([
            {'name' => 'header', 'elements' => ['download', 'headline']},
            {'name' => 'footer', 'elements' => ['contactform', 'text']},
            {'name' => 'sidebar', 'elements' => ['teaser']}
          ])
        end

        it "should return the 'nil cell'" do
          FactoryGirl.create(:cell, name: 'header', page: page)
          FactoryGirl.create(:cell, name: 'footer', page: page)
          FactoryGirl.create(:cell, name: 'sidebar', page: page)
          element.available_page_cell_names(page).should == ['for_other_elements']
        end
      end
    end

    describe '#content_by_type' do
      before(:each) do
        @element = FactoryGirl.create(:element, :name => 'headline')
        @content = @element.contents.first
      end

      context "with namespaced essence type" do
        it "should return content by passing a essence type" do
          @element.content_by_type('Alchemy::EssenceText').should == @content
        end
      end

      context "without namespaced essence type" do
        it "should return content by passing a essence type" do
          @element.content_by_type('EssenceText').should == @content
        end
      end
    end

    describe '#display_name' do
      let(:element) { Element.new(name: 'article') }

      it "should call .display_name_for" do
        Element.should_receive(:display_name_for).with(element.name)
        element.display_name
      end
    end

    describe '#display_name_with_preview_text' do
      let(:element) { FactoryGirl.build_stubbed(:element, name: 'Foo') }

      it "returns a string with display name and preview text" do
        element.stub(:preview_text).and_return('Fula')
        element.display_name_with_preview_text.should == "Foo: Fula"
      end
    end

    describe '#dom_id' do
      let(:element) { FactoryGirl.build_stubbed(:element) }

      it "returns an string from element name and id" do
        element.dom_id.should == "#{element.name}_#{element.id}"
      end
    end

    describe '#new_from_scratch' do
      it "should initialize an element by name from scratch" do
        el = Element.new_from_scratch({:name => 'article'})
        el.should be_valid
      end

      it "should raise an error if the given name is not defined in the elements.yml" do
        expect { Element.new_from_scratch({:name => 'foobar'}) }.to raise_error
      end

      it "should take the first part of an given name containing a hash (#)" do
        el = Element.new_from_scratch({:name => 'article#header'})
        el.name.should == "article"
      end

      it "should merge given attributes into defined ones" do
        el = Element.new_from_scratch({:name => 'article', :page_id => 1})
        el.page_id.should == 1
      end

      it "should not have forbidden attributes from definition" do
        el = Element.new_from_scratch({:name => 'article'})
        el.contents.should == []
      end
    end

    describe '#preview_text' do
      let(:element) { FactoryGirl.build_stubbed(:element) }
      let(:content) { mock_model(Content, preview_text: 'Lorem', preview_content?: false) }
      let(:content_2) { mock_model(Content, preview_text: 'Lorem', preview_content?: false) }
      let(:preview_content) { mock_model(Content, preview_text: 'Lorem', preview_content?: true) }

      context "without a content marked as preview" do
        let(:contents) { [content, content_2] }
        before { element.stub(:contents).and_return(contents) }

        it "returns the preview text of first content found" do
          content.should_receive(:preview_text).with(30)
          element.preview_text
        end
      end

      context "with a content marked as preview" do
        let(:contents) { [content, preview_content] }
        before { element.stub(:contents).and_return(contents) }

        it "should return the preview_text of this content" do
          preview_content.should_receive(:preview_text).with(30)
          element.preview_text
        end
      end

      context "without any contents present" do
        before { element.stub(:contents).and_return([]) }

        it "should return nil" do
          element.preview_text.should be_nil
        end
      end
    end

    context 'previous and next elements.' do
      let(:page) { FactoryGirl.create(:language_root_page) }

      before(:each) do
        @element1 = FactoryGirl.create(:element, :page => page, :name => 'headline')
        @element2 = FactoryGirl.create(:element, :page => page)
        @element3 = FactoryGirl.create(:element, :page => page, :name => 'text')
      end

      describe '#prev' do
        it "should return previous element on same page" do
          @element3.prev.should == @element2
        end

        context "with name as parameter" do
          it "should return previous of this kind" do
            @element3.prev('headline').should == @element1
          end
        end
      end

      describe '#next' do
        it "should return next element on same page" do
          @element2.next.should == @element3
        end

        context "with name as parameter" do
          it "should return next of this kind" do
            @element1.next('text').should == @element3
          end
        end
      end
    end

    context 'retrieving contents, essences and ingredients' do
      let(:element) { FactoryGirl.create(:element, :name => 'news', :create_contents_after_create => true) }

      it "should return an ingredient by name" do
        element.ingredient('news_headline').should == EssenceText.first.ingredient
      end

      it "should return the content for rss title" do
        element.content_for_rss_title.should == element.contents.find_by_name('news_headline')
      end

      it "should return the content for rss descdefinitionription" do
        element.content_for_rss_description.should == element.contents.find_by_name('body')
      end

      context 'if no content is defined as rss title' do
        before { element.stub(content_descriptions: []) }

        it "should return nil" do
          element.content_for_rss_title.should be_nil
        end
      end

      context 'if no content is defined as rss description' do
        before { element.stub(content_descriptions: []) }

        it "should return nil" do
          element.content_for_rss_description.should be_nil
        end
      end
    end

    describe '#update_contents' do
      subject { element.update_contents(params) }

      let(:page)    { build_stubbed(:page) }
      let(:element) { build_stubbed(:element, page: page) }
      let(:content) { double(:content, id: 1) }

      before { element.stub(:contents).and_return([content]) }

      context "with attributes hash is nil" do
        let(:params) { nil }
        it { should be_true }
      end

      context "with valid attributes hash" do
        let(:params) { {"#{content.id}" => {body: 'Title'}} }

        context 'with passing validations' do
          before do
            content.should_receive(:update_essence).with({body: 'Title'}).and_return(true)
          end

          it { should be_true }
        end

        context 'with failing validations' do
          it "adds error and returns false" do
            content.should_receive(:update_essence).with({body: 'Title'}).and_return(false)
            should be_false
            element.errors.should_not be_empty
          end
        end
      end
    end

    describe '.after_update' do
      context 'with touchable pages' do
        let(:locker)  { mock_model('DummyUser') }
        let(:page)    { create(:page) }
        let(:element) { create(:element, page: page) }
        let(:now)     { Time.now }
        let(:pages)   { [page] }

        before do
          Alchemy.user_class.stub(:stamper).and_return(locker.id)
          Time.stub(now: now)
        end

        it "updates page timestamps" do
          element.should_receive(:touchable_pages).and_return(pages)
          pages.should_receive(:update_all).with({updated_at: now, updater_id: locker.id})
          element.save
        end

        it "updates page userstamps" do
          element.save
          page.reload
          page.updater_id.should eq(locker.id)
        end
      end
    end

    describe '#taggable?' do
      let(:element) { FactoryGirl.build(:element) }

      context "definition has 'taggable' key with true value" do
        it "should return true" do
          element.stub(:definition).and_return({'name' => 'article', 'taggable' => true})
          element.taggable?.should be_true
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          element.stub(:definition).and_return({'name' => 'article', 'taggable' => 'foo'})
          element.taggable?.should be_false
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          element.stub(:definition).and_return({'name' => 'article'})
          element.taggable?.should be_false
        end
      end
    end

    describe '#trash!' do
      let(:element)         { FactoryGirl.create(:element, page_id: 1, cell_id: 1) }
      let(:trashed_element) { element.trash! ; element }
      subject               { trashed_element }

      it             { should_not be_public }
      it             { should be_folded }
      its(:position) { should be_nil }
      specify        { expect { element.trash! }.to_not change(element, :page_id) }
      specify        { expect { element.trash! }.to_not change(element, :cell_id) }

      context "with already one trashed element on the same page" do
        let(:element_2) { FactoryGirl.create(:element, page_id: 1) }
        before {
          trashed_element
          element_2
        }

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

    it_behaves_like "having a hint" do
      let(:subject) { Element.new }
    end

  end
end
