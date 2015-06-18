# encoding: UTF-8

require 'spec_helper'

module Alchemy
  describe Page do

    let(:rootpage)      { Page.root }
    let(:language)      { Language.default }
    let(:klingonian)    { create(:klingonian) }
    let(:language_root) { create(:language_root_page) }
    let(:page)          { mock_model(Page, page_layout: 'foo') }
    let(:public_page)   { create(:public_page) }
    let(:news_page)     { create(:public_page, page_layout: 'news', do_not_autogenerate: false) }


    # Validations

    context 'validations' do
      context "Creating a normal content page" do
        let(:contentpage)              { build(:page) }
        let(:with_same_urlname)        { create(:page, urlname: "existing_twice") }
        let(:global_with_same_urlname) { create(:page, urlname: "existing_twice", layoutpage: true) }

        context "when its urlname exists as global page" do
          before { global_with_same_urlname }

          it "it should be possible to save." do
            contentpage.urlname = "existing_twice"
            expect(contentpage).to be_valid
          end
        end

        it "should validate the page_layout" do
          contentpage.page_layout = nil
          expect(contentpage).not_to be_valid
          contentpage.valid?
          expect(contentpage.errors[:page_layout].size).to eq(1)
        end

        it "should validate the parent_id" do
          contentpage.parent_id = nil
          expect(contentpage).not_to be_valid
          contentpage.valid?
          expect(contentpage.errors[:parent_id].size).to eq(1)
        end

        context 'with page having same urlname' do
          before { with_same_urlname }

          it "should not be valid" do
            contentpage.urlname = 'existing_twice'
            expect(contentpage).not_to be_valid
          end
        end

        context "with url_nesting set to true" do
          let(:other_parent) { create(:page, parent_id: Page.root.id) }

          before do
            allow(Config).to receive(:get).and_return(true)
            with_same_urlname
          end

          it "should only validate urlname dependent of parent" do
            contentpage.urlname = 'existing_twice'
            contentpage.parent_id = other_parent.id
            expect(contentpage).to be_valid
          end

          it "should validate urlname dependent of parent" do
            contentpage.urlname = 'existing_twice'
            expect(contentpage).not_to be_valid
          end
        end
      end

      context "creating the rootpage without parent_id and page_layout" do
        let(:rootpage) { build(:page, parent_id: nil, page_layout: nil, name: 'Rootpage') }

        before do
          Page.delete_all
        end

        it "should be valid" do
          expect(rootpage).to be_valid
        end
      end

      context "saving a systempage" do
        let(:systempage) { build(:systempage) }

        it "should not validate the page_layout" do
          expect(systempage).to be_valid
        end
      end

      context 'saving an external page' do
        let(:external_page) { build(:page, page_layout: 'external') }

        it "does not pass with invalid url given" do
          external_page.urlname = 'not, a valid page url'
          expect(external_page).to_not be_valid
        end

        it "only be valid with correct url given" do
          external_page.urlname = 'www.google.com&utf_src=alchemy;page_id=%20'
          expect(external_page).to be_valid
        end

        context 'on create' do
          it "is valid without urlname given" do
            external_page.urlname = ''
            expect(external_page).to be_valid
          end
        end

        context 'on update' do
          before { external_page.save! }

          it "is not valid without urlname given" do
            external_page.urlname = ''
            expect(external_page).to_not be_valid
          end
        end
      end
    end


    # Callbacks

    context 'callbacks' do
      let(:page) do
        create(:page, name: 'My Testpage', language: language, parent_id: language_root.id)
      end

      context 'before_save' do
        it "should not set the title automatically if the name changed but title is not blank" do
          page.name = "My Renaming Test"
          page.save; page.reload
          expect(page.title).to eq("My Testpage")
        end

        it "should not automatically set the title if it changed its value" do
          page.title = "I like SEO"
          page.save; page.reload
          expect(page.title).to eq("I like SEO")
        end
      end

      context 'after_update' do
        context "urlname has changed" do
          it "should store legacy url if page is not redirect to external page" do
            page.urlname = 'new-urlname'
            page.save!
            expect(page.legacy_urls).not_to be_empty
            expect(page.legacy_urls.first.urlname).to eq('my-testpage')
          end

          it "should not store legacy url if page is redirect to external page" do
            page.urlname = 'new-urlname'
            page.page_layout = "external"
            page.save!
            expect(page.legacy_urls).to be_empty
          end

          it "should not store legacy url twice for same urlname" do
            page.urlname = 'new-urlname'
            page.save!
            page.urlname = 'my-testpage'
            page.save!
            page.urlname = 'another-urlname'
            page.save!
            expect(page.legacy_urls.select { |u| u.urlname == 'my-testpage' }.size).to eq(1)
          end
        end

        context "urlname has not changed" do
          it "should not store a legacy url" do
            page.urlname = 'my-testpage'
            page.save!
            expect(page.legacy_urls).to be_empty
          end
        end

        context "public has changed" do
          it "should update published_at" do
            expect {
              page.update_attributes!(public: true)
            }.to change {page.read_attribute(:published_at) }
          end

          it "should not update already set published_at" do
            page.update_attributes!(published_at: 2.weeks.ago)
            expect {
              page.update_attributes!(public: true)
            }.to_not change { page.read_attribute(:published_at) }
          end
        end

        context "public has not changed" do
          it "should not update published_at" do
            page.update_attributes!(name: 'New Name')
            expect(page.read_attribute(:published_at)).to be_nil
          end
        end
      end

      context 'after_move' do
        let(:parent_1) { create(:page, name: 'Parent 1', visible: true) }
        let(:parent_2) { create(:page, name: 'Parent 2', visible: true) }
        let(:page)     { create(:page, parent_id: parent_1.id, name: 'Page', visible: true) }

        it "updates the urlname" do
          expect(page.urlname).to eq('parent-1/page')
          page.move_to_child_of parent_2
          expect(page.urlname).to eq('parent-2/page')
        end

        context 'of an external page' do
          let(:external) { create(:page, parent_id: parent_1.id, name: 'external', page_layout: 'external', urlname: 'http://google.com') }

          it "the urlname does not get updated" do
            external.move_to_child_of parent_2
            expect(external.urlname).to eq('http://google.com')
          end
        end
      end

      context "Saving a normal page" do
        let(:page) do
          build(:page, language_code: nil, language: klingonian, do_not_autogenerate: false)
        end

        it "sets the language code" do
          page.save!
          expect(page.language_code).to eq("kl")
        end

        it "autogenerates the elements" do
          page.save!
          expect(page.elements).not_to be_empty
        end

        context 'with elements already on the page' do
          before do
            page.elements << create(:element, name: 'header')
          end

          it "does not autogenerate" do
            page.save!
            expect(page.elements.select { |e| e.name == 'header' }.length).to eq(1)
          end
        end

        context "with cells" do
          before do
            allow(page).to receive(:definition) do
              {'cells' => %w(header main)}
            end
          end

          context 'with elements defined in cells' do
            before do
              allow(page).to receive(:cell_definitions) do
                [{'name' => 'header', 'elements' => %w(article)}]
              end
            end

            it "has the  generated elements in their cells" do
              page.save!
              expect(page.cells.where(name: 'header').first.elements).not_to be_empty
            end
          end

          context "and no elements in cell definitions" do
            before do
              allow(page).to receive(:cell_definitions) do
                [{'name' => 'header', 'elements' => []}]
              end
            end

            it "should have the elements in the nil cell" do
              page.save!
              expect(page.cells.collect(&:elements).flatten).to be_empty
            end
          end
        end

        context "with children getting restricted set to true" do
          before do
            page.save
            @child1 = create(:page, name: 'Child 1', parent_id: page.id)
            page.reload
            page.restricted = true
            page.save
          end

          it "restricts all its children" do
            @child1.reload
            expect(@child1.restricted?).to be_truthy
          end
        end

        context "with restricted parent gets created" do
          before do
            page.save
            page.parent.update!(restricted: true)
            @new_page = create(:page, name: 'New Page', parent_id: page.id)
          end

          it "is also be restricted" do
            expect(@new_page.restricted?).to be_truthy
          end
        end

        context "with do_not_autogenerate set to true" do
          before do
            page.do_not_autogenerate = true
          end

          it "should not autogenerate the elements" do
            page.save
            expect(page.elements).to be_empty
          end
        end
      end

      context "Creating a systempage" do
        let!(:page) { create(:systempage) }

        it "does not get the language code from language" do
          expect(page.language_code).to be_nil
        end

        it "does not autogenerate the elements" do
          expect(page.elements).to be_empty
        end
      end

      context "after changing the page layout" do
        let(:news_element) { news_page.elements.find_by(name: 'news') }

        it "all elements not allowed on this page should be trashed" do
          expect(news_page.elements.trashed).to be_empty
          news_page.update_attributes(page_layout: 'standard')
          trashed = news_page.elements.trashed.pluck(:name)
          expect(trashed).to eq(['news'])
          expect(trashed).to_not include('article', 'header')
        end

        it "should autogenerate elements" do
          news_page.update_attributes(page_layout: 'contact')
          expect(news_page.elements.pluck(:name)).to include('contactform')
        end
      end
    end


    # ClassMethods (a-z)

    describe '.all_from_clipboard_for_select' do
      context "with clipboard holding pages having non unique page layout" do
        it "should return the pages" do
          page_1 = create(:page, language: language)
          page_2 = create(:page, language: language, name: 'Another page')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to include(page_1, page_2)
        end
      end

      context "with clipboard holding a page having unique page layout" do
        it "should not return any pages" do
          page_1 = create(:page, language: language, page_layout: 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to eq([])
        end
      end

      context "with clipboard holding two pages. One having a unique page layout." do
        it "should return one page" do
          page_1 = create(:page, language: language, page_layout: 'standard')
          page_2 = create(:page, name: 'Another page', language: language, page_layout: 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to eq([page_1])
        end
      end
    end

    describe '.all_locked' do
      it "should return 1 page that is blocked by a user at the moment" do
        create(:public_page, locked: true, name: 'First Public Child', parent_id: language_root.id, language: language)
        expect(Page.all_locked.size).to eq(1)
      end
    end

    describe '.all_locked_by' do
      let(:user) { double(:user, id: 1, class: DummyUser) }

      before do
        create(:public_page, locked: true, locked_by: 53) # This page must not be part of the collection
        allow(user.class)
          .to receive(:primary_key)
          .and_return('id')
      end

      it "should return the correct page collection blocked by a certain user" do
        page = create(:public_page, locked: true, locked_by: 1)
        expect(Page.all_locked_by(user).pluck(:id)).to eq([page.id])
      end

      context 'with user class having a different primary key' do
        let(:user) { double(:user, user_id: 123, class: DummyUser) }

        before do
          allow(user.class)
            .to receive(:primary_key)
            .and_return('user_id')
        end

        it "should return the correct page collection blocked by a certain user" do
          page = create(:public_page, locked: true, locked_by: 123)
          expect(Page.all_locked_by(user).pluck(:id)).to eq([page.id])
        end
      end
    end

    describe '.ancestors_for' do
      let(:lang_root) { Page.language_root_for(Language.default.id) }
      let(:parent)    { create(:public_page) }
      let(:page)      { create(:public_page, parent_id: parent.id) }

      it "returns an array of all parents including self" do
        expect(Page.ancestors_for(page)).to eq([lang_root, parent, page])
      end

      it "does not include the root page" do
        expect(Page.ancestors_for(page)).not_to include(Page.root)
      end

      context "with current page nil" do
        it "should return an empty array" do
          expect(Page.ancestors_for(nil)).to eq([])
        end
      end
    end

    describe '.contentpages' do
      let!(:layoutroot) do
        Page.find_or_create_layout_root_for(klingonian.id)
      end

      let!(:layoutpage) do
        create :public_page, {
          name: 'layoutpage',
          layoutpage: true,
          parent_id: layoutroot.id,
          language: klingonian
        }
      end

      let!(:klingonian_lang_root) do
        create :language_root_page, {
          name: 'klingonian_lang_root',
          layoutpage: nil,
          language: klingonian
        }
      end

      let!(:contentpage) do
        create :public_page, {
          name: 'contentpage',
          parent_id: language_root.id,
          language: language
        }
      end

      it "returns a collection of contentpages" do
        expect(Page.contentpages.to_a).to include(
          language_root,
          klingonian_lang_root,
          contentpage
        )
      end

      it "does not contain pages with attribute :layoutpage set to true" do
        expect(Page.contentpages.to_a.select { |p| p.layoutpage == true }).to be_empty
      end

      it "contains pages with attribute :layoutpage set to nil" do
        expect(Page.contentpages.to_a.select do |page|
          page.layoutpage == nil
        end).to include(klingonian_lang_root)
      end
    end

    describe '.copy' do
      let(:page) { create(:page, name: 'Source') }
      subject { Page.copy(page) }

      it "the copy should have added (copy) to name" do
        expect(subject.name).to eq("#{page.name} (Copy)")
      end

      context "page with tags" do
        before { page.tag_list = 'red, yellow'; page.save }

        it "the copy should have source tag_list" do
          # The order of tags varies between postgresql and sqlite/mysql
          # This is related to acts-as-taggable-on v.2.4.1
          # To fix the spec we sort the tags until the issue is solved (https://github.com/mbleigh/acts-as-taggable-on/issues/363)
          expect(subject.tag_list).not_to be_empty
          expect(subject.tag_list.sort).to eq(page.tag_list.sort)
        end
      end

      context "page with elements" do
        before { page.elements << create(:element) }

        it "the copy should have source elements" do
          expect(subject.elements).not_to be_empty
          expect(subject.elements.count).to eq(page.elements.count)
        end
      end

      context "page with trashed elements" do
        before do
          page.elements << create(:element)
          page.elements.first.trash!
        end

        it "the copy should not hold a copy of the trashed elements" do
          expect(subject.elements).to be_empty
        end
      end

      context "page with cells" do
        before { page.cells << create(:cell) }

        it "the copy should have source cells" do
          expect(subject.cells).not_to be_empty
          expect(subject.cells.count).to eq(page.cells.length) # It must be length, because!
        end
      end

      context "page with autogenerate elements" do
        before do
          page = create(:page)
          allow(page).to receive(:definition).and_return({'name' => 'standard', 'elements' => ['headline'], 'autogenerate' => ['headline']})
        end

        it "the copy should not autogenerate elements" do
          expect(subject.elements).to be_empty
        end
      end

      context "with different page name given" do
        subject { Page.copy(page, {name: 'Different name'}) }

        it "should take this name" do
          expect(subject.name).to eq('Different name')
        end
      end
    end

    describe '.create' do
      context "before/after filter" do
        it "should automatically set the title from its name" do
          page = create(:page, name: 'My Testpage', language: language, parent_id: language_root.id)
          expect(page.title).to eq('My Testpage')
        end

        it "should get a webfriendly urlname" do
          page = create(:page, name: 'klingon$&stößel ', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('klingon-stoessel')
        end

        context "with no name set" do
          it "should not set a urlname" do
            page = Page.create(name: '', language: language, parent_id: language_root.id)
            expect(page.urlname).to be_blank
          end
        end

        it "should generate a three letter urlname from two letter name" do
          page = create(:page, name: 'Au', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('-au')
        end

        it "should generate a three letter urlname from two letter name with umlaut" do
          page = create(:page, name: 'Aü', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('aue')
        end

        it "should generate a three letter urlname from one letter name" do
          page = create(:page, name: 'A', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('--a')
        end

        it "should add a user stamper" do
          page = create(:page, name: 'A', language: language, parent_id: language_root.id)
          expect(page.class.stamper_class.to_s).to eq('DummyUser')
        end

        context "with language given" do
          it "does not set the language from parent" do
            expect_any_instance_of(Page).not_to receive(:set_language_from_parent_or_default)
            Page.create!(name: 'A', parent_id: language_root.id, page_layout: 'standard', language: language)
          end
        end

        context "with no language given" do
          it "sets the language from parent" do
            expect_any_instance_of(Page).to receive(:set_language_from_parent_or_default)
            Page.create!(name: 'A', parent_id: language_root.id, page_layout: 'standard')
          end
        end
      end
    end

    describe '.find_or_create_layout_root_for' do
      subject { Page.find_or_create_layout_root_for(language_id) }

      let(:language)    { mock_model('Language', name: 'English') }
      let(:language_id) { language.id }

      before { allow(Language).to receive(:find).and_return(language) }

      context 'if no layout root page for given language id could be found' do
        before do
          expect(Page).to receive(:create!).and_return(page)
        end

        it "creates one" do
          is_expected.to eq(page)
        end
      end

      context 'if layout root page for given language id could be found' do
        let(:page) { mock_model('Page') }

        before do
          expect(Page).to receive(:layout_root_for).and_return(page)
        end

        it "returns layout root page" do
          is_expected.to eq(page)
        end
      end
    end

    describe '.language_roots' do
      it "should return 1 language_root" do
        create(:public_page, name: 'First Public Child', parent_id: language_root.id, language: language)
        expect(Page.language_roots.size).to eq(1)
      end
    end

    describe '.layoutpages' do
      it "should return 1 layoutpage" do
        create(:public_page, layoutpage: true, name: 'Layoutpage', parent_id: rootpage.id, language: language)
        expect(Page.layoutpages.size).to eq(1)
      end
    end

    describe '.not_locked' do
      it "should return pages that are not blocked by a user at the moment" do
        create(:public_page, locked: true, name: 'First Public Child', parent_id: language_root.id, language: language)
        create(:public_page, name: 'Second Public Child', parent_id: language_root.id, language: language)
        expect(Page.not_locked.size).to eq(3)
      end
    end

    describe '.not_restricted' do
      it "should return 2 accessible pages" do
        create(:public_page, name: 'First Public Child', restricted: true, parent_id: language_root.id, language: language)
        expect(Page.not_restricted.size).to eq(2)
      end
    end

    describe '.public' do
      it "should return pages that are public" do
        create(:public_page, name: 'First Public Child', parent_id: language_root.id, language: language)
        create(:public_page, name: 'Second Public Child', parent_id: language_root.id, language: language)
        expect(Page.published.size).to eq(3)
      end
    end

    describe '.restricted' do
      it "should return 1 restricted page" do
        create(:public_page, name: 'First Public Child', restricted: true, parent_id: language_root.id, language: language)
        expect(Page.restricted.size).to eq(1)
      end
    end

    describe '.rootpage' do
      it "should contain one rootpage" do
        expect(Page.rootpage).to be_instance_of(Page)
      end
    end

    describe '.visible' do
      it "should return 1 visible page" do
        create(:public_page, name: 'First Public Child', visible: true, parent_id: language_root.id, language: language)
        expect(Page.visible.size).to eq(1)
      end
    end


    # InstanceMethods (a-z)

    describe '#available_element_definitions' do
      let(:page) { build_stubbed(:public_page) }

      it "returns all element definitions of available elements" do
        expect(page.available_element_definitions).to be_an(Array)
        expect(page.available_element_definitions.collect { |e| e['name'] }).to include('header')
      end

      context "with unique elements already on page" do
        let(:element) { build_stubbed(:unique_element) }

        before do
          allow(page)
            .to receive(:elements)
            .and_return double(not_trashed: double(pluck: [element.name]))
        end

        it "does not return unique element definitions" do
          expect(page.available_element_definitions.collect { |e| e['name'] }).to include('article')
          expect(page.available_element_definitions.collect { |e| e['name'] }).not_to include('header')
        end
      end

      context 'limited amount' do
        let(:page) { build_stubbed(:page, page_layout: 'columns') }
        let(:unique_element) { build_stubbed(:unique_element, name: 'unique_headline') }
        let(:element_1) { build_stubbed(:element, name: 'column_headline') }
        let(:element_2) { build_stubbed(:element, name: 'column_headline') }
        let(:element_3) { build_stubbed(:element, name: 'column_headline') }

        before {
          allow(Element).to receive(:definitions).and_return([
            {
              'name' => 'column_headline',
              'amount' => 3,
              'contents' => [{'name' => 'headline', 'type' => 'EssenceText'}]
            },
            {
              'name' => 'unique_headline',
              'unique' => true,
              'amount' => 3,
              'contents' => [{'name' => 'headline', 'type' => 'EssenceText'}]
            }
          ])
          allow(PageLayout).to receive(:get).and_return({
            'name' => 'columns',
            'elements' => ['column_headline', 'unique_headline'],
            'autogenerate' => ['unique_headline', 'column_headline', 'column_headline', 'column_headline']
          })
          allow(page).to receive(:elements).and_return double(
            not_trashed: double(pluck: [
              unique_element.name,
              element_1.name,
              element_2.name,
              element_3.name
            ])
          )
        }

        it "should be readable" do
          element = page.element_definitions_by_name('column_headline').first
          expect(element['amount']).to be 3
        end

        it "should limit elements" do
          expect(page.available_element_definitions.collect { |e| e['name'] }).not_to include('column_headline')
        end

        it "should be ignored if unique" do
          expect(page.available_element_definitions.collect { |e| e['name'] }).not_to include('unique_headline')
        end
      end
    end

    describe '#available_element_names' do
      let(:page) { build_stubbed(:page) }

      it "returns all names of elements that could be placed on current page" do
        page.available_element_names == %w(header article)
      end
    end

    describe '#cache_key' do
      let(:page) do
        stub_model(Page, updated_at: Time.now, published_at: Time.now - 1.week)
      end

      subject { page.cache_key }

      before do
        expect(Page).to receive(:current_preview).and_return(preview)
      end

      context "when current page rendered in preview mode" do
        let(:preview) { page }

        it { is_expected.to eq("alchemy/pages/#{page.id}-#{page.updated_at}") }
      end

      context "when current page not in preview mode" do
        let(:preview) { nil }

        it { is_expected.to eq("alchemy/pages/#{page.id}-#{page.published_at}") }
      end
    end

    describe '#cell_definitions' do
      before do
        @page = build(:page, page_layout: 'foo')
        allow(@page).to receive(:definition).and_return({'name' => "foo", 'cells' => ["foo_cell"]})
        @cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
        allow(Cell).to receive(:definitions).and_return(@cell_descriptions)
      end

      it "should return all cell definitions for its page_layout" do
        expect(@page.cell_definitions).to eq(@cell_descriptions)
      end

      it "should return empty array if no cells defined in page layout" do
        allow(@page).to receive(:definition).and_return({'name' => "foo"})
        expect(@page.cell_definitions).to eq([])
      end
    end

    describe '#destroy' do
      context "with trashed but still assigned elements" do
        before { news_page.elements.map(&:trash!) }

        it "should not delete the trashed elements" do
          news_page.destroy
          expect(Element.trashed).not_to be_empty
        end
      end
    end

    describe '#element_definitions' do
      let(:page) { build_stubbed(:page) }
      subject { page.element_definitions }
      before { expect(Element).to receive(:definitions).and_return([{'name' => 'article'}, {'name' => 'header'}]) }

      it "returns all element definitions that could be placed on current page" do
        is_expected.to include({'name' => 'article'})
        is_expected.to include({'name' => 'header'})
      end
    end

    describe '#element_definitions_by_name' do
      let(:page) { build_stubbed(:public_page) }

      context "with no name given" do
        it "returns empty array" do
          expect(page.element_definitions_by_name(nil)).to eq([])
        end
      end

      context "with 'all' passed as name" do
        it "returns all element definitions" do
          expect(Element).to receive(:definitions)
          page.element_definitions_by_name('all')
        end
      end

      context "with :all passed as name" do
        it "returns all element definitions" do
          expect(Element).to receive(:definitions)
          page.element_definitions_by_name(:all)
        end
      end
    end

    describe '#element_definition_names' do
      let(:page) { build_stubbed(:public_page) }

      subject { page.element_definition_names }

      before do
        allow(page).to receive(:definition) { page_definition }
        allow(page).to receive(:cell_definitions) { cell_definitions }
      end

      context "with elements only assigned in page definition" do
        let(:page_definition) do
          {'elements' => %w(article)}
        end

        let(:cell_definitions) { [] }

        it "returns an array of the page's element names" do
          is_expected.to eq %w(article)
        end
      end

      context "with elements assigned only in cell definition" do
        before do
          allow(page).to receive(:definition).and_return({})
          allow(page).to receive(:cell_definitions) do
            [{'elements' => ['search']}]
          end
        end

        it "returns an array of the cell's element names" do
          is_expected.to eq(['search'])
        end
      end

      context "with elements assigned in page and cell definition" do
        let(:page_definition) do
          {'elements' => %w(header article)}
        end

        let(:cell_definitions) do
          [{'elements' => %w(search)}]
        end

        it "returns the combined element names" do
          is_expected.to eq %w(header article search)
        end

        context "and cell definition contains same element name as page definition" do
          let(:page_definition) do
            {'elements' => %w(header article)}
          end

          let(:cell_definitions) do
            [{'elements' => %w(header search)}]
          end

          it "includes no duplicates" do
            is_expected.to eq %w(header article search)
          end
        end
      end

      context "without elements assigned in page definition or cell definition" do
        let(:page_definition) { {} }
        let(:cell_definitions) { [] }

        it { is_expected.to eq([]) }
      end
    end

    describe '#elements_grouped_by_cells' do
      let(:page) { create(:public_page, do_not_autogenerate: false) }

      before do
        allow(PageLayout).to receive(:get).and_return({
          'name' => 'standard',
          'cells' => ['header'],
          'elements' => ['header', 'text'],
          'autogenerate' => ['header', 'text']
        })
        allow(Cell).to receive(:definitions).and_return([{
          'name' => "header",
          'elements' => ["header"]
        }])
      end

      it "should return elements grouped by cell" do
        elements = page.elements_grouped_by_cells
        expect(elements.keys.first).to be_instance_of(Cell)
        expect(elements.values.first.first).to be_instance_of(Element)
      end

      it "should only include elements beeing in a cell " do
        expect(page.elements_grouped_by_cells.keys).not_to include(nil)
      end
    end

    describe '#feed_elements' do
      it "should return all rss feed elements" do
        expect(news_page.feed_elements).not_to be_empty
        expect(news_page.feed_elements).to eq(Element.where(name: 'news').to_a)
      end
    end

    describe '#find_elements' do
      before do
        create(:element, public: false, page: public_page)
        create(:element, public: false, page: public_page)
      end

      context "with show_non_public argument TRUE" do
        it "should return all elements from empty options" do
          expect(public_page.find_elements({}, true).to_a).to eq(public_page.elements.to_a)
        end

        it "should only return the elements passed as options[:only]" do
          expect(public_page.find_elements({only: ['article']}, true).to_a).to eq(public_page.elements.named('article').to_a)
        end

        it "should not return the elements passed as options[:except]" do
          expect(public_page.find_elements({except: ['article']}, true).to_a).to eq(public_page.elements - public_page.elements.named('article').to_a)
        end

        it "should return elements offsetted" do
          expect(public_page.find_elements({offset: 2}, true).to_a).to eq(public_page.elements.offset(2))
        end

        it "should return elements limitted in count" do
          expect(public_page.find_elements({count: 1}, true).to_a).to eq(public_page.elements.limit(1))
        end
      end

      context "with options[:from_cell]" do
        let(:element) { build_stubbed(:element) }

        context "given as String" do
          context 'with elements present' do
            before do
              expect(public_page.cells)
                .to receive(:find_by_name)
                .and_return double(elements: double(offset: double(limit: double(published: [element]))))
            end

            it "returns only the elements from given cell" do
              expect(public_page.find_elements(from_cell: 'A Cell').to_a).to eq([element])
            end
          end

          context "that can not be found" do
            let(:elements) {[]}

            before do
              allow(elements)
                .to receive(:offset)
                .and_return double(limit: double(published: elements))
            end

            it "returns empty set" do
              expect(Element).to receive(:none).and_return(elements)
              expect(public_page.find_elements(from_cell: 'Lolo').to_a).to eq([])
            end

            it "loggs a warning" do
              expect(Rails.logger).to receive(:debug)
              public_page.find_elements(from_cell: 'Lolo')
            end
          end
        end

        context "given as cell object" do
          let(:cell) { build_stubbed(:cell, page: public_page) }

          it "returns only the elements from given cell" do
            expect(cell)
              .to receive(:elements)
              .and_return double(offset: double(limit: double(published: [element])))

            expect(public_page.find_elements(from_cell: cell).to_a).to eq([element])
          end
        end
      end

      context "with show_non_public argument FALSE" do
        it "should return all elements from empty arguments" do
          expect(public_page.find_elements().to_a).to eq(public_page.elements.published.to_a)
        end

        it "should only return the public elements passed as options[:only]" do
          expect(public_page.find_elements(only: ['article']).to_a).to eq(public_page.elements.published.named('article').to_a)
        end

        it "should return all public elements except the ones passed as options[:except]" do
          expect(public_page.find_elements(except: ['article']).to_a).to eq(public_page.elements.published.to_a - public_page.elements.published.named('article').to_a)
        end

        it "should return elements offsetted" do
          expect(public_page.find_elements({offset: 2}).to_a).to eq(public_page.elements.published.offset(2))
        end

        it "should return elements limitted in count" do
          expect(public_page.find_elements({count: 1}).to_a).to eq(public_page.elements.published.limit(1))
        end
      end
    end

    describe '#first_public_child' do
      before do
        create(:page, name: "First child", language: language, public: false, parent_id: language_root.id)
      end

      it "should return first_public_child" do
        first_public_child = create(:public_page, name: "First public child", language: language, parent_id: language_root.id)
        expect(language_root.first_public_child).to eq(first_public_child)
      end

      it "should return nil if no public child exists" do
        expect(language_root.first_public_child).to eq(nil)
      end
    end

    context 'folding' do
      let(:user) { mock_model('DummyUser') }

      describe '#fold!' do
        context "with folded status set to true" do
          it "should create a folded page for user" do
            public_page.fold!(user.id, true)
            expect(public_page.folded_pages.first.user_id).to eq(user.id)
          end
        end
      end

      describe '#folded?' do
        let(:page) { Page.new }

        context 'with user is a active record model' do
          before do
            expect(Alchemy.user_class).to receive(:'<').and_return(true)
          end

          context 'if page is folded' do
            before do
              expect(page)
                .to receive(:folded_pages)
                .and_return double(where: double(any?: true))
            end

            it "should return true" do
              expect(page.folded?(user.id)).to eq(true)
            end
          end

          context 'if page is not folded' do
            it "should return false" do
              expect(page.folded?(101093)).to eq(false)
            end
          end
        end
      end
    end

    describe '#get_language_root' do
      before { language_root }
      subject { public_page.get_language_root }

      it "returns the language root page" do
        is_expected.to eq language_root
      end
    end

    describe '#layout_description' do
      context 'if the page layout could not be found in the definition file' do
        let(:page) { build_stubbed(:page, page_layout: 'notexisting') }

        it "it loggs a warning." do
          expect(Alchemy::Logger).to receive(:warn)
          page.layout_description
        end

        it "it returns empty hash." do
          expect(page.layout_description).to eq({})
        end
      end

      context "for a language root page" do
        it "it returns the page layout description as hash." do
          expect(language_root.layout_description['name']).to eq('index')
        end

        it "it returns an empty hash for root page." do
          expect(rootpage.layout_description).to eq({})
        end
      end
    end

    describe '#lock_to!' do
      let(:page) { create(:page) }
      let(:user) { mock_model('DummyUser') }

      it "should set locked to true" do
        page.lock_to!(user)
        page.reload
        expect(page.locked).to eq(true)
      end

      it "should not update the timestamps " do
        expect { page.lock!(user) }.to_not change(page, :updated_at)
      end

      it "should set locked_by to the users id" do
        page.lock_to!(user)
        page.reload
        expect(page.locked_by).to eq(user.id)
      end
    end

    describe '#copy_and_paste' do
      let(:source) { build_stubbed(:page) }
      let(:new_parent) { build_stubbed(:page) }
      let(:page_name) { "Pagename (pasted)" }
      let(:copied_page) { mock_model('Page') }

      subject { Page.copy_and_paste(source, new_parent, page_name) }

      it "should copy the source page with the given name to the new parent" do
        expect(Page).to receive(:copy).with(source, {
          parent_id: new_parent.id,
          language: new_parent.language,
          name: page_name,
          title: page_name
          })
        subject
      end

      it "should return the copied page" do
        allow(Page).to receive(:copy).and_return(copied_page)
        expect(subject).to be_a(copied_page.class)
      end

      context "if source page has children" do
        it "should also copy and paste the children" do
          allow(Page).to receive(:copy).and_return(copied_page)
          allow(source).to receive(:children).and_return([mock_model('Page')])
          expect(source).to receive(:copy_children_to).with(copied_page)
          subject
        end
      end
    end

    context 'previous and next.' do
      let(:center_page)     { create(:public_page, name: 'Center Page') }
      let(:next_page)       { create(:public_page, name: 'Next Page') }
      let(:non_public_page) { create(:page, name: 'Not public Page') }
      let(:restricted_page) { create(:restricted_page, public: true) }

      before do
        public_page
        restricted_page
        non_public_page
        center_page
        next_page
      end

      describe '#previous' do
        it "should return the previous page on the same level" do
          expect(center_page.previous).to eq(public_page)
          expect(next_page.previous).to eq(center_page)
        end

        context "no previous page on same level present" do
          it "should return nil" do
            expect(public_page.previous).to be_nil
          end
        end

        context "with options restricted" do
          context "set to true" do
            it "returns previous restricted page" do
              expect(center_page.previous(restricted: true)).to eq(restricted_page)
            end
          end

          context "set to false" do
            it "skips restricted page" do
              expect(center_page.previous(restricted: false)).to eq(public_page)
            end
          end
        end

        context "with options public" do
          context "set to true" do
            it "returns previous public page" do
              expect(center_page.previous(public: true)).to eq(public_page)
            end
          end

          context "set to false" do
            it "skips public page" do
              expect(center_page.previous(public: false)).to eq(non_public_page)
            end
          end
        end
      end

      describe '#next' do
        it "should return the next page on the same level" do
          expect(center_page.next).to eq(next_page)
        end

        context "no next page on same level present" do
          it "should return nil" do
            expect(next_page.next).to be_nil
          end
        end
      end
    end

    describe '#publish!' do
      let(:page) { build_stubbed(:page, public: false) }
      let(:current_time) { Time.now }

      before do
        current_time
        allow(Time).to receive(:now).and_return(current_time)
        page.publish!
      end

      it "sets public attribute to true" do
        expect(page.public).to eq(true)
      end

      it "sets published_at attribute to current time" do
        expect(page.published_at).to eq(current_time)
      end
    end

    describe '#set_language_from_parent_or_default' do
      let(:default_language) { mock_model('Language', code: 'es') }
      let(:page) { Page.new }

      before { allow(page).to receive(:parent).and_return(parent) }

      subject { page }

      context "parent has a language" do
        let(:parent) { mock_model('Page', language: default_language, language_id: default_language.id, language_code: default_language.code) }

        before do
          page.send(:set_language_from_parent_or_default)
        end

        describe '#language_id' do
          subject { super().language_id }
          it { is_expected.to eq(parent.language_id) }
        end
      end

      context "parent has no language" do
        let(:parent) { mock_model('Page', language: nil, language_id: nil, language_code: nil) }

        before do
          allow(Language).to receive(:default).and_return(default_language)
          page.send(:set_language_from_parent_or_default)
        end

        describe '#language_id' do
          subject { super().language_id }
          it { is_expected.to eq(default_language.id) }
        end
      end
    end

    describe '#taggable?' do
      context "definition has 'taggable' key with true value" do
        it "should return true" do
          page = build(:page)
          allow(page).to receive(:definition).and_return({'name' => 'standard', 'taggable' => true})
          expect(page.taggable?).to be_truthy
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          page = build(:page)
          allow(page).to receive(:definition).and_return({'name' => 'standard', 'taggable' => 'foo'})
          expect(page.taggable?).to be_falsey
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          page = build(:page)
          allow(page).to receive(:definition).and_return({'name' => 'standard'})
          expect(page.taggable?).to be_falsey
        end
      end
    end

    describe '#unlock!' do
      let(:page) { create(:page, locked: true, locked_by: 1) }

      before do
        allow(page).to receive(:save).and_return(true)
      end

      it "should set the locked status to false" do
        page.unlock!
        page.reload
        expect(page.locked).to eq(false)
      end

      it "should not update the timestamps " do
        expect { page.unlock! }.to_not change(page, :updated_at)
      end

      it "should set locked_by to nil" do
        page.unlock!
        page.reload
        expect(page.locked_by).to eq(nil)
      end

      it "sets current preview to nil" do
        Page.current_preview = page
        page.unlock!
        expect(Page.current_preview).to be_nil
      end
    end

    context 'urlname updating' do
      let(:parentparent)  { create(:page, name: 'parentparent', visible: true) }
      let(:parent)        { create(:page, parent_id: parentparent.id, name: 'parent', visible: true) }
      let(:page)          { create(:page, parent_id: parent.id, name: 'page', visible: true) }
      let(:invisible)     { create(:page, parent_id: page.id, name: 'invisible', visible: false) }
      let(:contact)       { create(:page, parent_id: invisible.id, name: 'contact', visible: true) }
      let(:external)      { create(:page, parent_id: parent.id, name: 'external', page_layout: 'external', urlname: 'http://google.com') }
      let(:language_root) { parentparent.parent }

      context "with activated url_nesting" do
        before { allow(Config).to receive(:get).and_return(true) }

        it "should store all parents urlnames delimited by slash" do
          expect(page.urlname).to eq('parentparent/parent/page')
        end

        it "should not include the root page" do
          Page.root.update_column(:urlname, 'root')
          language_root.update(urlname: 'new-urlname')
          expect(language_root.urlname).not_to match(/root/)
        end

        it "should not include the language root page" do
          expect(page.urlname).not_to match(/startseite/)
        end

        it "should not include invisible pages" do
          expect(contact.urlname).not_to match(/invisible/)
        end

        context "after changing page's urlname" do
          it "updates urlnames of descendants" do
            page
            parentparent.urlname = 'new-urlname'
            parentparent.save!
            page.reload
            expect(page.urlname).to eq('new-urlname/parent/page')
          end

          context 'with descendants that are redirecting to external' do
            it "it skips this page" do
              external
              parent.urlname = 'new-urlname'
              parent.save!
              external.reload
              expect(external.urlname).to eq('http://google.com')
            end
          end

          it "should create a legacy url" do
            allow(page).to receive(:slug).and_return('foo')
            page.update_urlname!
            expect(page.legacy_urls).not_to be_empty
            expect(page.legacy_urls.pluck(:urlname)).to include('parentparent/parent/page')
          end
        end

        context "after updating my visibility" do
          it "should update urlnames of descendants" do
            page
            parentparent.visible = false
            parentparent.save!
            page.reload
            expect(page.urlname).to eq('parent/page')
          end
        end
      end

      context "with disabled url_nesting" do
        before { allow(Config).to receive(:get).and_return(false) }

        it "should only store my urlname" do
          expect(page.urlname).to eq('page')
        end
      end
    end

    describe "#update_node!" do

      let(:original_url) { "sample-url" }
      let(:page) { create(:page, language: language, parent_id: language_root.id, urlname: original_url, restricted: false) }
      let(:node) { TreeNode.new(10, 11, 12, 13, "another-url", true) }

      context "when nesting is enabled" do
        before { allow(Alchemy::Config).to receive(:get).with(:url_nesting) { true } }

        context "when page is not external" do

          before do
            expect(page).to receive(:redirects_to_external?).and_return(false)
          end

          it "should update all attributes" do
            page.update_node!(node)
            page.reload
            expect(page.lft).to eq(node.left)
            expect(page.rgt).to eq(node.right)
            expect(page.parent_id).to eq(node.parent)
            expect(page.depth).to eq(node.depth)
            expect(page.urlname).to eq(node.url)
            expect(page.restricted).to eq(node.restricted)
          end

          context "when url is the same" do
            let(:node) { TreeNode.new(10, 11, 12, 13, original_url, true) }

            it "should not create a legacy url" do
              page.update_node!(node)
              page.reload
              expect(page.legacy_urls.size).to eq(0)
            end
          end

          context "when url is not the same" do
            it "should create a legacy url" do
              page.update_node!(node)
              page.reload
              expect(page.legacy_urls.size).to eq(1)
            end
          end
        end

        context "when page is external" do
          before do
            expect(page)
              .to receive(:redirects_to_external?)
              .and_return(true)
          end

          it "should update all attributes except url" do
            page.update_node!(node)
            page.reload
            expect(page.lft).to eq(node.left)
            expect(page.rgt).to eq(node.right)
            expect(page.parent_id).to eq(node.parent)
            expect(page.depth).to eq(node.depth)
            expect(page.urlname).to eq(original_url)
            expect(page.restricted).to eq(node.restricted)
          end

          it "should not create a legacy url" do
            page.update_node!(node)
            page.reload
            expect(page.legacy_urls.size).to eq(0)
          end
        end
      end

      context "when nesting is disabled" do
        before do
          allow(Alchemy::Config).to receive(:get).with(:url_nesting) { false }
        end

        context "when page is not external" do
          before do
            allow(page).to receive(:redirects_to_external?).and_return(false)
          end

          it "should update all attributes except url" do
            page.update_node!(node)
            page.reload
            expect(page.lft).to eq(node.left)
            expect(page.rgt).to eq(node.right)
            expect(page.parent_id).to eq(node.parent)
            expect(page.depth).to eq(node.depth)
            expect(page.urlname).to eq(original_url)
            expect(page.restricted).to eq(node.restricted)
          end

          it "should not create a legacy url" do
            page.update_node!(node)
            page.reload
            expect(page.legacy_urls.size).to eq(0)
          end
        end

        context "when page is external" do
          before do
            expect(Alchemy::Config).to receive(:get).and_return(true)
            allow(page).to receive(:redirects_to_external?).and_return(true)
          end

          it "should update all attributes except url" do
            page.update_node!(node)
            page.reload
            expect(page.lft).to eq(node.left)
            expect(page.rgt).to eq(node.right)
            expect(page.parent_id).to eq(node.parent)
            expect(page.depth).to eq(node.depth)
            expect(page.urlname).to eq(original_url)
            expect(page.restricted).to eq(node.restricted)
          end

          it "should not create a legacy url" do
            page.update_node!(node)
            page.reload
            expect(page.legacy_urls.size).to eq(0)
          end
        end
      end
    end

    describe '#slug' do
      context "with parents path saved in urlname" do
        let(:page) { build(:page, urlname: 'root/parent/my-name')}

        it "should return the last part of the urlname" do
          expect(page.slug).to eq('my-name')
        end
      end

      context "with single urlname" do
        let(:page) { build(:page, urlname: 'my-name')}

        it "should return the last part of the urlname" do
          expect(page.slug).to eq('my-name')
        end
      end

      context "with nil as urlname" do
        let(:page) { build(:page, urlname: nil)}

        it "should return nil" do
          expect(page.slug).to be_nil
        end
      end
    end

    describe '#external_urlname' do
      let(:external_page) { build(:page, page_layout: 'external') }

      context 'with missing protocol' do
        before { external_page.urlname = 'google.com'}

        it "returns an urlname prefixed with http://" do
          expect(external_page.external_urlname).to eq 'http://google.com'
        end
      end

      context 'with protocol present' do
        before { external_page.urlname = 'ftp://google.com'}

        it "returns the urlname" do
          expect(external_page.external_urlname).to eq 'ftp://google.com'
        end
      end

      context 'beginngin with a slash' do
        before { external_page.urlname = '/internal-url'}

        it "returns the urlname" do
          expect(external_page.external_urlname).to eq '/internal-url'
        end
      end
    end

    context 'page status methods' do
      let(:page) { build(:page, public: true, visible: true, restricted: false, locked: false)}

      describe '#status' do
        it "returns a combined status hash" do
          expect(page.status).to eq({public: true, visible: true, restricted: false, locked: false})
        end
      end

      describe '#status_title' do
        it "returns a translated status string for public status" do
          expect(page.status_title(:public)).to eq('Page is published.')
        end

        it "returns a translated status string for visible status" do
          expect(page.status_title(:visible)).to eq('Page is visible in navigation.')
        end

        it "returns a translated status string for locked status" do
          expect(page.status_title(:locked)).to eq('')
        end

        it "returns a translated status string for restricted status" do
          expect(page.status_title(:restricted)).to eq('Page is not restricted.')
        end
      end
    end

    context 'indicate page editors' do
      let(:page) { Page.new }
      let(:user) { create(:alchemy_dummy_user, :as_editor) }

      describe '#creator' do
        before { page.update(creator_id: user.id) }

        it "returns the user that created the page" do
          expect(page.creator).to eq(user)
        end

        context 'with user class having a different primary key' do
          before do
            allow(Alchemy.user_class)
              .to receive(:primary_key)
              .and_return('user_id')

            allow(page)
              .to receive(:creator_id)
              .and_return(1)
          end

          it "returns the user that created the page" do
            expect(Alchemy.user_class)
              .to receive(:find_by)
              .with({'user_id' => 1})

            page.creator
          end
        end
      end

      describe '#updater' do
        before { page.update(updater_id: user.id) }

        it "returns the user that updated the page" do
          expect(page.updater).to eq(user)
        end

        context 'with user class having a different primary key' do
          before do
            allow(Alchemy.user_class)
              .to receive(:primary_key)
              .and_return('user_id')

            allow(page)
              .to receive(:updater_id)
              .and_return(1)
          end

          it "returns the user that updated the page" do
            expect(Alchemy.user_class)
              .to receive(:find_by)
              .with({'user_id' => 1})

            page.updater
          end
        end
      end

      describe '#locker' do
        before { page.update(locked_by: user.id) }

        it "returns the user that locked the page" do
          expect(page.locker).to eq(user)
        end

        context 'with user class having a different primary key' do
          before do
            allow(Alchemy.user_class)
              .to receive(:primary_key)
              .and_return('user_id')

            allow(page)
              .to receive(:locked_by)
              .and_return(1)
          end

          it "returns the user that locked the page" do
            expect(Alchemy.user_class)
              .to receive(:find_by)
              .with({'user_id' => 1})

            page.locker
          end
        end
      end

      context 'with user that can not be found' do
        it 'does not raise not found error' do
          %w(creator updater locker).each do |user_type|
            expect {
              page.send(user_type)
            }.to_not raise_error
          end
        end
      end

      context 'with user class having a name accessor' do
        let(:user) { double(name: 'Paul Page') }

        describe '#creator_name' do
          before { allow(page).to receive(:creator).and_return(user) }

          it "returns the name of the creator" do
            expect(page.creator_name).to eq('Paul Page')
          end
        end

        describe '#updater_name' do
          before { allow(page).to receive(:updater).and_return(user) }

          it "returns the name of the updater" do
            expect(page.updater_name).to eq('Paul Page')
          end
        end

        describe '#locker_name' do
          before { allow(page).to receive(:locker).and_return(user) }

          it "returns the name of the current page editor" do
            expect(page.locker_name).to eq('Paul Page')
          end
        end
      end

      context 'with user class not having a name accessor' do
        let(:user) { Alchemy.user_class.new }

        describe '#creator_name' do
          before { allow(page).to receive(:creator).and_return(user) }

          it "returns unknown" do
            expect(page.creator_name).to eq('unknown')
          end
        end

        describe '#updater_name' do
          before { allow(page).to receive(:updater).and_return(user) }

          it "returns unknown" do
            expect(page.updater_name).to eq('unknown')
          end
        end

        describe '#locker_name' do
          before { allow(page).to receive(:locker).and_return(user) }

          it "returns unknown" do
            expect(page.locker_name).to eq('unknown')
          end
        end
      end
    end

    describe '#controller_and_action' do
      let(:page) { Page.new }

      context 'if the page has a custom controller defined in its description' do
        before do
          allow(page).to receive(:has_controller?).and_return(true)
          allow(page).to receive(:layout_description).and_return({'controller' => 'comments', 'action' => 'index'})
        end
        it "should return a Hash with controller and action key-value pairs" do
          expect(page.controller_and_action).to eq({controller: '/comments', action: 'index'})
        end
      end
    end

    it_behaves_like "having a hint" do
      let(:subject) { Page.new }
    end

    describe '#layout_partial_name' do
      let(:page) { Page.new(page_layout: 'Standard Page') }

      it "returns a partial renderer compatible name" do
        expect(page.layout_partial_name).to eq('standard_page')
      end
    end

    describe '#published_at' do
      context 'with published_at date set' do
        let(:published_at) { Time.now }
        let(:page)         { build_stubbed(:page, published_at: published_at) }

        it "returns the published_at value from database" do
          expect(page.published_at).to eq(published_at)
        end
      end

      context 'with published_at is nil' do
        let(:updated_at) { Time.now }
        let(:page)       { build_stubbed(:page, published_at: nil, updated_at: updated_at) }

        it "returns the updated_at value" do
          expect(page.published_at).to eq(updated_at)
        end
      end
    end

  end
end
