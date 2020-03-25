# frozen_string_literal: true

require 'rails_helper'

module Alchemy
  describe Page do
    let(:rootpage)      { Page.root }
    let(:language)      { Language.default }
    let(:klingon)       { create(:alchemy_language, :klingon) }
    let(:language_root) { create(:alchemy_page, :language_root) }
    let(:page)          { mock_model(Page, page_layout: 'foo') }
    let(:public_page)   { create(:alchemy_page, :public) }
    let(:news_page)     { create(:alchemy_page, :public, page_layout: 'news', autogenerate_elements: true) }

    it { is_expected.to have_one(:site) }

    # Validations

    context 'validations' do
      context "Creating a normal content page" do
        let(:contentpage)              { build(:alchemy_page) }
        let(:with_same_urlname)        { create(:alchemy_page, urlname: "existing_twice") }
        let(:global_with_same_urlname) { create(:alchemy_page, urlname: "existing_twice", layoutpage: true) }

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
          let(:other_parent) { create(:alchemy_page, parent_id: Page.root.id, visible: true) }

          before do
            stub_alchemy_config(:url_nesting, true)
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
        let(:rootpage) { build(:alchemy_page, parent_id: nil, page_layout: nil, name: 'Rootpage') }

        before do
          Page.delete_all
        end

        it "should be valid" do
          expect(rootpage).to be_valid
        end
      end

      context "saving a systempage" do
        let(:systempage) { build(:alchemy_page, :system) }

        it "should not validate the page_layout" do
          expect(systempage).to be_valid
        end
      end
    end

    # Callbacks

    context 'callbacks' do
      let(:page) do
        create(:alchemy_page, name: 'My Testpage', language: language, parent_id: language_root.id)
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
          it "should store legacy url" do
            page.urlname = 'new-urlname'
            page.save!
            expect(page.legacy_urls).not_to be_empty
            expect(page.legacy_urls.first.urlname).to eq('my-testpage')
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

        context "set_published_at hook" do
          let(:current_time) { Time.current.change(usec: 0) }
          let(:page) do
            create(:alchemy_page, public_on: public_on, published_at: published_at)
          end

          before do
            allow(Time).to receive(:current).and_return(current_time)
            page.save!
          end

          context "page is scheduled for publication" do
            let(:public_on) { current_time + 3.hours }

            context "and published_at is nil" do
              let(:published_at) { nil }

              it "should set published_at to current time" do
                expect(page.published_at).to eq(current_time)
              end
            end

            context "and published_at is already set" do
              let(:published_at) { public_on }

              it "should not set published_at" do
                expect(page.published_at).to eq(public_on)
              end
            end
          end

          context "page is not public and not scheduled for publication" do
            let(:public_on) { nil }
            let(:published_at) { nil }

            it "should not update published_at" do
              expect(page.read_attribute(:published_at)).to eq(nil)
            end
          end
        end
      end

      context 'after_move' do
        let(:parent_1) { create(:alchemy_page, name: 'Parent 1', visible: true) }
        let(:parent_2) { create(:alchemy_page, name: 'Parent 2', visible: true) }
        let(:page)     { create(:alchemy_page, parent_id: parent_1.id, name: 'Page', visible: true) }

        it "updates the urlname" do
          expect(page.urlname).to eq('parent-1/page')
          page.move_to_child_of parent_2
          expect(page.urlname).to eq('parent-2/page')
        end
      end

      context "Saving a normal page" do
        let(:page) do
          build(:alchemy_page, language_code: nil, language: klingon, autogenerate_elements: true)
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
            page.elements << create(:alchemy_element, name: 'header')
          end

          it "does not autogenerate" do
            page.save!
            expect(page.elements.select { |e| e.name == 'header' }.length).to eq(1)
          end
        end

        context "with children getting restricted set to true" do
          before do
            page.save
            @child1 = create(:alchemy_page, name: 'Child 1', parent_id: page.id)
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
            @new_page = create(:alchemy_page, name: 'New Page', parent_id: page.id)
          end

          it "is also be restricted" do
            expect(@new_page.restricted?).to be_truthy
          end
        end

        context "with autogenerate_elements set to false" do
          before do
            page.autogenerate_elements = false
          end

          it "should not autogenerate the elements" do
            page.save
            expect(page.elements).to be_empty
          end
        end
      end

      context "Creating a systempage" do
        let!(:page) { create(:alchemy_page, :system) }

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
          expect(news_page.trashed_elements).to be_empty
          news_page.update(page_layout: 'standard')
          trashed = news_page.trashed_elements.pluck(:name)
          expect(trashed).to eq(['news'])
          expect(trashed).to_not include('article', 'header')
        end

        it "should autogenerate elements" do
          news_page.update(page_layout: 'contact')
          expect(news_page.elements.pluck(:name)).to include('contactform')
        end
      end

      context 'destruction' do
        let!(:page) { create(:alchemy_page, autogenerate_elements: true) }

        it 'destroys elements along with itself' do
          expect { page.destroy! }.to change(Alchemy::Element, :count).from(3).to(0)
        end
      end
    end

    # ClassMethods (a-z)

    describe '.all_from_clipboard_for_select' do
      context "with clipboard holding pages having non unique page layout" do
        it "should return the pages" do
          page_1 = create(:alchemy_page, language: language)
          page_2 = create(:alchemy_page, language: language, name: 'Another page')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to include(page_1, page_2)
        end
      end

      context "with clipboard holding a page having unique page layout" do
        it "should not return any pages" do
          page_1 = create(:alchemy_page, language: language, page_layout: 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to eq([])
        end
      end

      context "with clipboard holding two pages. One having a unique page layout." do
        it "should return one page" do
          page_1 = create(:alchemy_page, language: language, page_layout: 'standard')
          page_2 = create(:alchemy_page, name: 'Another page', language: language, page_layout: 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          expect(Page.all_from_clipboard_for_select(clipboard, language.id)).to eq([page_1])
        end
      end
    end

    describe '.locked' do
      it "should return 1 page that is blocked by a user at the moment" do
        create(:alchemy_page, :public, :locked, name: 'First Public Child', parent_id: language_root.id, language: language)
        expect(Page.locked.size).to eq(1)
      end
    end

    describe '.locked_by' do
      let(:user) { double(:user, id: 1, class: DummyUser) }

      before do
        create(:alchemy_page, :public, :locked, locked_by: 53) # This page must not be part of the collection
        allow(user.class)
          .to receive(:primary_key)
          .and_return('id')
      end

      it "should return the correct page collection blocked by a certain user" do
        page = create(:alchemy_page, :public, :locked, locked_by: 1)
        expect(Page.locked_by(user).pluck(:id)).to eq([page.id])
      end

      context 'with user class having a different primary key' do
        let(:user) { double(:user, user_id: 123, class: DummyUser) }

        before do
          allow(user.class)
            .to receive(:primary_key)
            .and_return('user_id')
        end

        it "should return the correct page collection blocked by a certain user" do
          page = create(:alchemy_page, :public, :locked, locked_by: 123)
          expect(Page.locked_by(user).pluck(:id)).to eq([page.id])
        end
      end
    end

    describe '.ancestors_for' do
      let(:lang_root) { Page.language_root_for(Language.default.id) }
      let(:parent)    { create(:alchemy_page, :public) }
      let(:page)      { create(:alchemy_page, :public, parent_id: parent.id) }

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
        Page.find_or_create_layout_root_for(klingon.id)
      end

      let!(:layoutpage) do
        create :alchemy_page, :public, {
          name: 'layoutpage',
          layoutpage: true,
          parent_id: layoutroot.id,
          language: klingon
        }
      end

      let!(:klingon_lang_root) do
        create :alchemy_page, :language_root, {
          name: 'klingon_lang_root',
          layoutpage: nil,
          language: klingon
        }
      end

      let!(:contentpage) do
        create :alchemy_page, :public, {
          name: 'contentpage',
          parent_id: language_root.id,
          language: language
        }
      end

      it "returns a collection of contentpages" do
        expect(Page.contentpages.to_a).to include(
          language_root,
          klingon_lang_root,
          contentpage
        )
      end

      it "does not contain pages with attribute :layoutpage set to true" do
        expect(Page.contentpages.to_a.select { |p| p.layoutpage == true }).to be_empty
      end

      it "contains pages with attribute :layoutpage set to nil" do
        expect(Page.contentpages.to_a.select do |page|
          page.layoutpage.nil?
        end).to include(klingon_lang_root)
      end
    end

    describe '.copy' do
      let(:page) { create(:alchemy_page, name: 'Source') }

      subject { Page.copy(page) }

      it "the copy should have added (copy) to name" do
        expect(subject.name).to eq("#{page.name} (Copy)")
      end

      context 'a visible page' do
        let(:page) { create(:alchemy_page, name: 'Source', visible: true) }

        it "the copy should not be visible" do
          expect(subject.visible).to be(false)
        end
      end

      context 'a public page' do
        let(:page) { create(:alchemy_page, :public, name: 'Source', public_until: Time.current) }

        it "the copy should not be public" do
          expect(subject.public_on).to be(nil)
          expect(subject.public_until).to be(nil)
        end
      end

      context 'a locked page' do
        let(:page) do
          create(:alchemy_page, :public, :locked, name: 'Source')
        end

        it "the copy should not be locked" do
          expect(subject.locked?).to be(false)
          expect(subject.locked_by).to be(nil)
        end
      end

      context "page with tags" do
        before do
          page.tag_list = 'red, yellow'
          page.save!
        end

        it "the copy should have source tag_list" do
          expect(subject.tag_list).not_to be_empty
          expect(subject.tag_list).to match_array(page.tag_list)
        end
      end

      context "page with elements" do
        before { page.elements << create(:alchemy_element) }

        it "the copy should have source elements" do
          expect(subject.elements).not_to be_empty
          expect(subject.elements.count).to eq(page.elements.count)
        end
      end

      context "page with trashed elements" do
        before do
          page.elements << create(:alchemy_element)
          page.elements.first.trash!
        end

        it "the copy should not hold a copy of the trashed elements" do
          expect(subject.elements).to be_empty
        end
      end

      context "page with fixed elements" do
        before { page.elements << create(:alchemy_element, :fixed) }

        it "the copy should have source fixed elements" do
          expect(subject.fixed_elements).not_to be_empty
          expect(subject.fixed_elements.count).to eq(page.fixed_elements.count)
        end
      end

      context "page with autogenerate elements" do
        before do
          page = create(:alchemy_page)
          allow(page).to receive(:definition).and_return({
            'name' => 'standard',
            'elements' => ['headline'],
            'autogenerate' => ['headline']
          })
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
          page = create(:alchemy_page, name: 'My Testpage', language: language, parent_id: language_root.id)
          expect(page.title).to eq('My Testpage')
        end

        it "should get a webfriendly urlname" do
          page = create(:alchemy_page, name: 'klingon$&stößel ', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('klingon-stoessel')
        end

        context "with no name set" do
          it "should not set a urlname" do
            page = Page.create(name: '', language: language, parent_id: language_root.id)
            expect(page.urlname).to be_blank
          end
        end

        it "should generate a three letter urlname from two letter name" do
          page = create(:alchemy_page, name: 'Au', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('-au')
        end

        it "should generate a three letter urlname from two letter name with umlaut" do
          page = create(:alchemy_page, name: 'Aü', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('aue')
        end

        it "should generate a three letter urlname from one letter name" do
          page = create(:alchemy_page, name: 'A', language: language, parent_id: language_root.id)
          expect(page.urlname).to eq('--a')
        end

        it "should add a user stamper" do
          page = create(:alchemy_page, name: 'A', language: language, parent_id: language_root.id)
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
      subject { Page.find_or_create_layout_root_for(language.id) }

      let!(:root_page) { create(:alchemy_page, :root) }
      let(:language)   { create(:alchemy_language, name: 'English') }

      context 'if no layout root page for given language id is present' do
        it "creates one" do
          expect {
            subject
          }.to change { Page.count }.by(1)
        end
      end

      context 'if layout root page for given language id is present' do
        let!(:page) do
          create :alchemy_page,
            layoutpage: true,
            parent_id: root_page.id,
            language_id: language.id
        end

        it "returns layout root page" do
          is_expected.to eq(page)
        end
      end
    end

    describe '.language_roots' do
      it "should return 1 language_root" do
        create(:alchemy_page, :public, name: 'First Public Child', parent_id: language_root.id, language: language)
        expect(Page.language_roots.size).to eq(1)
      end
    end

    describe '.layoutpages' do
      it "should return 1 layoutpage" do
        create(:alchemy_page, :public, layoutpage: true, name: 'Layoutpage', parent_id: rootpage.id, language: language)
        expect(Page.layoutpages.size).to eq(1)
      end
    end

    describe '.not_locked' do
      it "should return pages that are not blocked by a user at the moment" do
        create(:alchemy_page, :public, :locked, name: 'First Public Child', parent_id: language_root.id, language: language)
        create(:alchemy_page, :public, name: 'Second Public Child', parent_id: language_root.id, language: language)
        expect(Page.not_locked.size).to eq(3)
      end
    end

    describe '.not_restricted' do
      it "should return 2 accessible pages" do
        create(:alchemy_page, :public, name: 'First Public Child', restricted: true, parent_id: language_root.id, language: language)
        expect(Page.not_restricted.size).to eq(2)
      end
    end

    describe '.published' do
      subject(:published) { Page.published }

      let!(:public_one) do
        create :alchemy_page, :public,
          name: 'First Public Child',
          parent_id: language_root.id,
          language: language
      end

      let!(:public_two) do
        create :alchemy_page, :public,
          name: 'Second Public Child',
          parent_id: language_root.id,
          language: language
      end

      let!(:non_public_page) do
        create :alchemy_page,
          name: 'Non Public Child',
          parent_id: language_root.id,
          language: language
      end

      it "returns public available pages" do
        expect(published).to include(public_one)
        expect(published).to include(public_two)
        expect(published).to_not include(non_public_page)
      end
    end

    describe '.public_language_roots' do
      it "should return pages that public language roots" do
        create(:alchemy_page, :public, name: 'First Public Child', parent_id: language_root.id, language: language)
        expect(Page.public_language_roots.size).to eq(1)
      end
    end

    describe '.restricted' do
      it "should return 1 restricted page" do
        create(:alchemy_page, :public, name: 'First Public Child', restricted: true, parent_id: language_root.id, language: language)
        expect(Page.restricted.size).to eq(1)
      end
    end

    describe '.root' do
      context 'when root page is present' do
        let!(:root_page) { Page.root }

        it 'returns root page' do
          expect(Page.root).to eq(root_page)
        end
      end

      context 'when no root page is present yet' do
        before do
          Page.delete_all
        end

        it "creates and returns root page" do
          expect {
            Page.root
          }.to change { Page.count }.by(1)
        end
      end
    end

    describe '.visible' do
      it "should return 1 visible page" do
        create(:alchemy_page, :public, name: 'First Public Child', visible: true, parent_id: language_root.id, language: language)
        expect(Page.visible.size).to eq(1)
      end
    end

    # InstanceMethods (a-z)

    describe '#available_element_definitions' do
      subject { page.available_element_definitions }

      let(:page) { create(:alchemy_page, :public) }

      it "returns all element definitions of available elements" do
        expect(subject).to be_an(Array)
        expect(subject.collect { |e| e['name'] }).to include('header')
      end

      context "with unique elements already on page" do
        let!(:element) { create(:alchemy_element, :unique, page: page) }

        it "does not return unique element definitions" do
          expect(subject.collect { |e| e['name'] }).to include('article')
          expect(subject.collect { |e| e['name'] }).not_to include('header')
        end
      end

      context 'limited amount' do
        let(:page) { create(:alchemy_page, page_layout: 'columns') }

        let!(:unique_element) do
          create(:alchemy_element, :unique, name: 'unique_headline', page: page)
        end

        let!(:element_1) { create(:alchemy_element, name: 'column_headline', page: page) }
        let!(:element_2) { create(:alchemy_element, name: 'column_headline', page: page) }
        let!(:element_3) { create(:alchemy_element, name: 'column_headline', page: page) }

        before do
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
        end

        it "should be readable" do
          element = page.element_definitions_by_name('column_headline').first
          expect(element['amount']).to be 3
        end

        it "should limit elements" do
          expect(subject.collect { |e| e['name'] }).not_to include('column_headline')
        end

        it "should be ignored if unique" do
          expect(subject.collect { |e| e['name'] }).not_to include('unique_headline')
        end
      end
    end

    describe '#available_elements_within_current_scope' do
      let(:page) { create(:alchemy_page, page_layout: 'columns') }
      let(:nestable_element) { create(:alchemy_element, :with_nestable_elements) }
      let(:currently_available_elements) { page.available_elements_within_current_scope(nestable_element) }

      context "When unique element is already nested" do
        before do
          nestable_element.nested_elements << create(:alchemy_element, name: 'slide', unique: true, page: page)
          page.elements << nestable_element
        end

        it "returns no available elements" do
          expect(currently_available_elements).to eq([])
        end
      end

      context "When unique element has not be nested" do
        it "returns available elements" do
          expect(currently_available_elements.collect { |e| e['name'] }).to include('slide')
        end
      end
    end

    describe '#available_element_names' do
      let(:page) { build_stubbed(:alchemy_page) }

      it "returns all names of elements that could be placed on current page" do
        page.available_element_names == %w(header article)
      end
    end

    describe '#cache_key' do
      let(:page) do
        stub_model(Page, updated_at: Time.current, published_at: Time.current - 1.week)
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

    describe "#all_elements" do
      let(:page) { create(:alchemy_page) }
      let!(:element_1) { create(:alchemy_element, page: page) }
      let!(:element_2) { create(:alchemy_element, page: page) }
      let!(:element_3) { create(:alchemy_element, page: page) }

      before do
        element_3.move_to_top
      end

      it 'returns a ordered active record collection of elements on that page' do
        expect(page.all_elements).to eq([element_3, element_1, element_2])
      end

      context 'with nestable elements' do
        let!(:nestable_element) do
          create(:alchemy_element, page: page)
        end

        let!(:nested_element) do
          create(:alchemy_element, name: 'slide', parent_element: nestable_element, page: page)
        end

        it 'contains nested elements of an element' do
          expect(page.all_elements).to include(nested_element)
        end
      end

      context 'with trashed elements' do
        let(:trashed_element) { create(:alchemy_element, page: page).tap(&:trash!) }

        it 'contains trashed elements' do
          expect(page.all_elements).to include(trashed_element)
        end
      end

      context 'with hidden elements' do
        let(:hidden_element) { create(:alchemy_element, page: page, public: false) }

        it 'contains hidden elements' do
          expect(page.all_elements).to include(hidden_element)
        end
      end

      context 'with fixed elements' do
        let(:fixed_element) { create(:alchemy_element, page: page, fixed: true) }

        it 'contains hidden elements' do
          expect(page.all_elements).to include(fixed_element)
        end
      end
    end

    describe "#elements" do
      let(:page) { create(:alchemy_page) }
      let!(:element_1) { create(:alchemy_element, page: page) }
      let!(:element_2) { create(:alchemy_element, page: page) }
      let!(:element_3) { create(:alchemy_element, page: page) }

      before do
        element_3.move_to_top
      end

      it 'returns a ordered active record collection of elements on that page' do
        expect(page.elements).to eq([element_3, element_1, element_2])
      end

      context 'with nestable elements' do
        let(:nestable_element) { create(:alchemy_element, :with_nestable_elements) }

        before do
          nestable_element.nested_elements << create(:alchemy_element, name: 'slide')
          page.elements << nestable_element
        end

        it 'does not contain nested elements of an element' do
          expect(nestable_element.nested_elements).to_not be_empty
          expect(page.elements).to_not include(nestable_element.nested_elements.first)
        end
      end

      context 'with trashed elements' do
        let(:trashed_element) { create(:alchemy_element, page: page) }

        before do
          trashed_element.trash!
        end

        it 'does not contain trashed elements' do
          expect(page.elements).to_not include(trashed_element)
        end
      end

      context 'with hidden elements' do
        let(:hidden_element) { create(:alchemy_element, page: page, public: false) }

        it 'does not contain hidden elements' do
          expect(page.elements).to_not include(hidden_element)
        end
      end
    end

    describe "#fixed_elements" do
      let(:page) { create(:alchemy_page) }
      let!(:element_1) { create(:alchemy_element, fixed: true, page: page) }
      let!(:element_2) { create(:alchemy_element, fixed: true, page: page) }
      let!(:element_3) { create(:alchemy_element, fixed: true, page: page) }

      before do
        element_3.move_to_top
      end

      it 'returns a ordered active record collection of fixed elements on that page' do
        expect(page.fixed_elements).to eq([element_3, element_1, element_2])
      end

      context 'with trashed fixed elements' do
        let(:trashed_element) { create(:alchemy_element, page: page, fixed: true) }

        before do
          trashed_element.trash!
        end

        it 'does not contain trashed fixed elements' do
          expect(page.fixed_elements).to_not include(trashed_element)
        end
      end

      context 'with hidden fixed elements' do
        let(:hidden_element) { create(:alchemy_element, page: page, fixed: true, public: false) }

        it 'does not contain hidden fixed elements' do
          expect(page.fixed_elements).to_not include(hidden_element)
        end
      end
    end

    describe '#element_definitions' do
      let(:page) { build_stubbed(:alchemy_page) }
      subject { page.element_definitions }
      before { expect(Element).to receive(:definitions).and_return([{'name' => 'article'}, {'name' => 'header'}]) }

      it "returns all element definitions that could be placed on current page" do
        is_expected.to include({'name' => 'article'})
        is_expected.to include({'name' => 'header'})
      end
    end

    describe '#descendent_element_definitions' do
      let(:page) { build_stubbed(:alchemy_page, page_layout: 'standard') }

      subject(:descendent_element_definitions) { page.descendent_element_definitions }

      it "returns all element definitions including the nestable element definitions" do
        is_expected.to include(Alchemy::Element.definition_by_name('slider'))
        is_expected.to include(Alchemy::Element.definition_by_name('slide'))
      end

      context 'with nestable element being defined on multiple elements' do
        before do
          expect(page).to receive(:element_definition_names) do
            %w(slider gallery)
          end
          expect(Element).to receive(:definitions).at_least(:once) do
            [
              {'name' => 'slider', 'nestable_elements' => %w(slide)},
              {'name' => 'gallery', 'nestable_elements' => %w(slide)},
              {'name' => 'slide'}
            ]
          end
        end

        it 'only includes the definition once' do
          slide_definitions = descendent_element_definitions.select { |d| d['name'] == 'slide' }
          expect(slide_definitions.length).to eq(1)
        end
      end
    end

    describe '#element_definitions_by_name' do
      let(:page) { build_stubbed(:alchemy_page, :public) }

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
      let(:page) { build_stubbed(:alchemy_page, :public) }

      subject { page.element_definition_names }

      before do
        allow(page).to receive(:definition) { page_definition }
      end

      context "with elements assigned in page definition" do
        let(:page_definition) do
          {'elements' => %w(article)}
        end

        it "returns an array of the page's element names" do
          is_expected.to eq %w(article)
        end
      end

      context "without elements assigned in page definition" do
        let(:page_definition) { {} }

        it { is_expected.to eq([]) }
      end
    end

    describe '#feed_elements' do
      let(:news_element) { create(:alchemy_element, name: 'news', public: false, page: news_page) }

      it "should return all published rss feed elements" do
        expect(news_page.feed_elements).not_to be_empty
        expect(news_page.feed_elements).to eq(Element.where(name: 'news').available.to_a)
      end

      it "should not return unpublished rss feed elements" do
        expect(news_page.feed_elements).not_to include(news_element)
      end

      it "should not return trashed rss feed elements" do
        news_element.update(public: true)
        news_element.trash!
        expect(news_page.feed_elements).not_to include(news_element)
      end
    end

    describe '#find_elements' do
      subject { page.find_elements(options) }

      let(:page) { build(:alchemy_page) }
      let(:options) { {} }
      let(:finder) { instance_double(Alchemy::ElementsFinder) }

      it 'passes self and all options to elements finder' do
        expect(Alchemy::ElementsFinder).to receive(:new).with(options) { finder }
        expect(finder).to receive(:elements).with(page: page)
        subject
      end

      context 'with a custom finder given in options' do
        let(:options) do
          { finder: CustomNewsElementsFinder.new }
        end

        it 'uses that to load elements to render' do
          expect(subject.map(&:name)).to eq(['news'])
        end
      end
    end

    describe '#first_public_child' do
      before do
        create :alchemy_page,
          name: "First child",
          language: language,
          parent_id: language_root.id
      end

      context "with existing public child" do
        let!(:first_public_child) do
          create :alchemy_page, :public,
          name: "First public child",
          language: language,
          parent_id: language_root.id
        end

        it "should return first_public_child" do
          expect(language_root.first_public_child).to eq(first_public_child)
        end
      end

      it "should return nil if no public child exists" do
        expect(language_root.first_public_child).to eq(nil)
      end
    end

    context 'folding' do
      let(:user) { create(:alchemy_dummy_user) }

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
            allow(Alchemy.user_class).to receive(:'<').and_return(true)
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
              expect(page.folded?(101_093)).to eq(false)
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

    describe '#definition' do
      context 'if the page layout could not be found in the definition file' do
        let(:page) { build_stubbed(:alchemy_page, page_layout: 'notexisting') }

        it "it loggs a warning." do
          expect(Alchemy::Logger).to receive(:warn)
          page.definition
        end

        it "it returns empty hash." do
          expect(page.definition).to eq({})
        end
      end

      context "for a language root page" do
        it "it returns the page layout definition as hash." do
          expect(language_root.definition['name']).to eq('index')
        end

        it "it returns an empty hash for root page." do
          expect(rootpage.definition).to eq({})
        end
      end
    end

    describe '#lock_to!' do
      let(:page) { create(:alchemy_page) }
      let(:user) { mock_model('DummyUser') }

      it "sets locked_at timestamp" do
        page.lock_to!(user)
        page.reload
        expect(page.locked_at?).to be(true)
        expect(page.locked_at).to be_a(Time)
      end

      it "does not update the updated_at " do
        expect { page.lock_to!(user) }.to_not change(page, :updated_at)
      end

      it "sets locked_by to the users id" do
        page.lock_to!(user)
        page.reload
        expect(page.locked_by).to eq(user.id)
      end
    end

    describe '#copy_and_paste' do
      let(:source) { build_stubbed(:alchemy_page) }
      let(:new_parent) { build_stubbed(:alchemy_page) }
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
      let(:center_page)     { create(:alchemy_page, :public, name: 'Center Page') }
      let(:next_page)       { create(:alchemy_page, :public, name: 'Next Page') }
      let(:non_public_page) { create(:alchemy_page, name: 'Not public Page') }
      let(:restricted_page) { create(:alchemy_page, :restricted, :public) }

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

    describe '#editable_by?' do
      subject { page.editable_by?(user) }

      let(:user) { mock_model('DummyUser') }
      let(:page) { create(:alchemy_page) }

      context "template defines one alchemy role" do
        before do
          allow(page).to receive(:definition).and_return({"editable_by" => ["freelancer"]})
        end

        context 'user has matching alchemy role' do
          before do
            allow(user).to receive(:alchemy_roles).at_least(:once) { ["freelancer"] }
          end

          it { is_expected.to be(true) }
        end
        context 'user has a different alchemy role' do
          before do
            allow(user).to receive(:alchemy_roles).at_least(:once) { ["editor"] }
          end

          it { is_expected.to be(false) }
        end
      end

      context "template defines multiple alchemy roles" do
        before do
          allow(page).to receive(:definition).and_return({"editable_by" => ["freelancer", "admin"]})
        end

        context 'user has matching alchemy role' do
          before do
            allow(user).to receive(:alchemy_roles).at_least(:once) { ["freelancer", "member"] }
          end

          it { is_expected.to be(true) }
        end
        context 'user has a different alchemy role' do
          before do
            allow(user).to receive(:alchemy_roles).at_least(:once) { ["editor", "leader"] }
          end

          it { is_expected.to be(false) }
        end
      end

      context "template has no alchemy role defined" do
        before do
          allow(page).to receive(:definition).and_return({})
        end

        context 'user has matching alchemy role' do
          before do
            allow(user).to receive(:alchemy_roles).at_least(:once) { ["freelancer", "member"] }
          end

          it { is_expected.to be(true) }
        end
      end
    end

    describe '#public_on' do
      subject(:public_on) { page.public_on }

      context 'when is fixed attribute' do
        let(:page) do
          create(:alchemy_page, page_layout: 'readonly')
        end

        it 'returns the fixed value' do
          is_expected.to eq(nil)
        end
      end

      context 'when is not fixed attribute' do
        let(:page) do
          create(:alchemy_page, page_layout: 'standard', public_on: '2016-11-01')
        end

        it 'returns value' do
          is_expected.to eq('2016-11-01'.to_time(:utc))
        end
      end
    end

    describe '#public_until' do
      subject(:public_until) { page.public_until }

      context 'when is fixed attribute' do
        let(:page) do
          create(:alchemy_page, page_layout: 'readonly')
        end

        it 'returns the fixed value' do
          is_expected.to eq(nil)
        end
      end

      context 'when is not fixed attribute' do
        let(:page) do
          create(:alchemy_page, page_layout: 'standard', public_until: '2016-11-01')
        end

        it 'returns value' do
          is_expected.to eq('2016-11-01'.to_time(:utc))
        end
      end
    end

    describe '#public?' do
      subject { page.public? }

      context "when public_on is not set" do
        let(:page) { create(:alchemy_page, public_on: nil) }

        it { is_expected.to be(false) }
      end

      context "when public_on is set to past date" do
        context "and public_until is set to nil" do
          let(:page) do
            create :alchemy_page,
              public_on: Time.current - 2.days,
              public_until: nil
          end

          it { is_expected.to be(true) }
        end

        context "and public_until is set to future date" do
          let(:page) do
            create :alchemy_page,
              public_on: Time.current - 2.days,
              public_until: Time.current + 2.days
          end

          it { is_expected.to be(true) }
        end

        context "and public_until is set to past date" do
          let(:page) do
            create :alchemy_page,
              public_on: Time.current - 2.days,
              public_until: Time.current - 1.days
          end

          it { is_expected.to be(false) }
        end
      end

      context "when public_on is set to future date" do
        let(:page) { create(:alchemy_page, public_on: Time.current + 2.days) }

        it { is_expected.to be(false) }
      end
    end

    describe '#publish!' do
      let(:current_time) { Time.current.change(usec: 0) }
      let(:page) do
        create(:alchemy_page,
          public_on: public_on,
          public_until: public_until,
          published_at: published_at
        )
      end
      let(:published_at) { nil }
      let(:public_on)    { nil }
      let(:public_until) { nil }

      before do
        allow(Time).to receive(:current).and_return(current_time)
        page.publish!
      end

      context "with unpublished page" do
        it "sets public_on and published_at", aggregate_failures: true do
          expect(page.published_at).to eq(current_time)
          expect(page.public_on).to    eq(current_time)
          expect(page.public_until).to eq(nil)
        end
      end

      context "with already published page" do
        let(:past_time)    { current_time - 3.weeks }
        let(:published_at) { past_time }
        let(:public_on)    { past_time }

        it "only sets published_at", aggregate_failures: true do
          expect(page.published_at).to eq(current_time)
          expect(page.public_on).to    eq(public_on)
          expect(page.public_until).to eq(nil)
        end

        context "that is scheduled for unpublishing" do
          let(:public_until) { current_time + 2.weeks }

          it "does not change public_until" do
            expect(page.public_until).to eq(public_until)
          end
        end
      end

      context "with page scheduled for publishing" do
        let(:public_on) { current_time + 3.hours }

        it "resets public_on and sets published_at", aggregate_failures: true do
          expect(page.published_at).to eq(current_time)
          expect(page.public_on).to    eq(current_time)
          expect(page.public_until).to eq(nil)
        end
      end

      context "with not anymore published page" do
        let(:past_time)    { current_time - 3.weeks }
        let(:published_at) { past_time }
        let(:public_on)    { past_time }
        let(:public_until) { past_time + 1.week }

        it "resets public_on and published_at and sets public_until to nil",
          aggregate_failures: true do
          expect(page.published_at).to eq(current_time)
          expect(page.public_on).to    eq(public_on)
          expect(page.public_until).to eq(nil)
        end
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
          page = build(:alchemy_page)
          allow(page).to receive(:definition).and_return({'name' => 'standard', 'taggable' => true})
          expect(page.taggable?).to be_truthy
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          page = build(:alchemy_page)
          allow(page).to receive(:definition).and_return({'name' => 'standard', 'taggable' => 'foo'})
          expect(page.taggable?).to be_falsey
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          page = build(:alchemy_page)
          allow(page).to receive(:definition).and_return({'name' => 'standard'})
          expect(page.taggable?).to be_falsey
        end
      end
    end

    describe '#unlock!' do
      let(:page) { create(:alchemy_page, :locked) }

      before do
        allow(page).to receive(:save).and_return(true)
      end

      it "should set the locked status to false" do
        page.unlock!
        page.reload
        expect(page.locked?).to eq(false)
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
      let(:parentparent)  { create(:alchemy_page, name: 'parentparent', visible: true) }
      let(:parent)        { create(:alchemy_page, parent_id: parentparent.id, name: 'parent', visible: true) }
      let(:page)          { create(:alchemy_page, parent_id: parent.id, name: 'page', visible: true) }
      let(:invisible)     { create(:alchemy_page, parent_id: page.id, name: 'invisible', visible: false) }
      let(:contact)       { create(:alchemy_page, parent_id: invisible.id, name: 'contact', visible: true) }
      let(:language_root) { parentparent.parent }

      context "with activated url_nesting" do
        before do
          stub_alchemy_config(:url_nesting, true)
        end

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

        context "with an invisible parent" do
          before { parent.update_attribute(:visible, false) }

          it "does not change if set_urlname is called" do
            expect { page.send(:set_urlname) }.not_to change { page.urlname }
          end

          it "does not change if update_urlname! is called" do
            expect { page.update_urlname! }.not_to change { page.urlname }
          end
        end

        context "after changing page's urlname" do
          it "updates urlnames of descendants" do
            page
            parentparent.urlname = 'new-urlname'
            parentparent.save!
            page.reload
            expect(page.urlname).to eq('new-urlname/parent/page')
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
        before do
          stub_alchemy_config(:url_nesting, false)
        end

        it "should only store my urlname" do
          expect(page.urlname).to eq('page')
        end
      end
    end

    describe "#update_node!" do
      let(:original_url) { "sample-url" }
      let(:page) { create(:alchemy_page, language: language, parent_id: language_root.id, urlname: original_url, restricted: false) }
      let(:node) { TreeNode.new(10, 11, 12, 13, "another-url", true) }

      context "when nesting is enabled" do
        before do
          stub_alchemy_config(:url_nesting, true)
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

      context "when nesting is disabled" do
        before do
          stub_alchemy_config(:url_nesting, false)
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

    describe '#cache_page?' do
      let(:page) { Page.new(page_layout: "news") }
      subject { page.cache_page? }

      before { Rails.application.config.action_controller.perform_caching = true }
      after { Rails.application.config.action_controller.perform_caching = false }

      it 'returns true when everthing is alright' do
        expect(subject).to be true
      end

      it 'returns false when the Rails app does not perform caching' do
        Rails.application.config.action_controller.perform_caching = false
        expect(subject).to be false
      end

      it 'returns false when caching is deactivated in the Alchemy config' do
        stub_alchemy_config(:cache_pages, false)
        expect(subject).to be false
      end

      it 'returns false when the page layout is set to cache = false' do
        page_layout = PageLayout.get('news')
        page_layout['cache'] = false
        allow(PageLayout).to receive(:get).with('news').and_return(page_layout)
        expect(subject).to be false
      end

      it 'returns false when the page layout is set to searchresults = true' do
        page_layout = PageLayout.get('news')
        page_layout['searchresults'] = true
        allow(PageLayout).to receive(:get).with('news').and_return(page_layout)
        expect(subject).to be false
      end
    end

    describe '#slug' do
      context "with parents path saved in urlname" do
        let(:page) { build(:alchemy_page, urlname: 'root/parent/my-name') }

        it "should return the last part of the urlname" do
          expect(page.slug).to eq('my-name')
        end
      end

      context "with single urlname" do
        let(:page) { build(:alchemy_page, urlname: 'my-name') }

        it "should return the last part of the urlname" do
          expect(page.slug).to eq('my-name')
        end
      end

      context "with nil as urlname" do
        let(:page) { build(:alchemy_page, urlname: nil) }

        it "should return nil" do
          expect(page.slug).to be_nil
        end
      end
    end

    context 'page status methods' do
      let(:page) do
        build(:alchemy_page, :public, visible: true, restricted: false)
      end

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

    describe 'page editor methods' do
      let(:user) { create(:alchemy_dummy_user, :as_editor) }

      describe '#creator' do
        let(:page) { Page.new(creator: user) }
        subject(:creator) { page.creator }

        it "returns the user that created the page" do
          is_expected.to eq(user)
        end

        it 'uses the primary key defined on user class' do
          expect(Alchemy.user_class).to receive(:primary_key).at_least(:once) { :id }
          subject
        end
      end

      describe '#updater' do
        let(:page) { Page.new(updater: user) }
        subject(:updater) { page.updater }

        it "returns the user that updated the page" do
          is_expected.to eq(user)
        end

        it 'uses the primary key defined on user class' do
          expect(Alchemy.user_class).to receive(:primary_key).at_least(:once) { :id }
          subject
        end
      end

      describe '#locker' do
        let(:page) { Page.new(locker: user) }
        subject(:locker) { page.locker }

        it "returns the user that updated the page" do
          is_expected.to eq(user)
        end

        it 'uses the primary key defined on user class' do
          expect(Alchemy.user_class).to receive(:primary_key).at_least(:once) { :id }
          subject
        end
      end

      context 'with user class having a name accessor' do
        let(:user) { build(:alchemy_dummy_user, name: 'Paul Page') }

        describe '#creator_name' do
          let(:page) { Page.new(creator: user) }

          it "returns the name of the creator" do
            expect(page.creator_name).to eq('Paul Page')
          end
        end

        describe '#updater_name' do
          let(:page) { Page.new(updater: user) }

          it "returns the name of the updater" do
            expect(page.updater_name).to eq('Paul Page')
          end
        end

        describe '#locker_name' do
          let(:page) { Page.new(locker: user) }

          it "returns the name of the current page editor" do
            expect(page.locker_name).to eq('Paul Page')
          end
        end
      end

      context 'with user class returning nil for name' do
        let(:user) { Alchemy.user_class.new }

        describe '#creator_name' do
          let(:page) { Page.new(creator: user) }

          it "returns unknown" do
            expect(page.creator_name).to eq('unknown')
          end
        end

        describe '#updater_name' do
          let(:page) { Page.new(updater: user) }

          it "returns unknown" do
            expect(page.updater_name).to eq('unknown')
          end
        end

        describe '#locker_name' do
          let(:page) { Page.new(locker: user) }

          it "returns unknown" do
            expect(page.locker_name).to eq('unknown')
          end
        end
      end

      context 'with user class not responding to name' do
        let(:user) { Alchemy.user_class.new }

        before do
          expect(user).to receive(:respond_to?).with(:name) { false }
        end

        describe '#creator_name' do
          let(:page) { Page.new(creator: user) }

          it "returns unknown" do
            expect(page.creator_name).to eq('unknown')
          end
        end

        describe '#updater_name' do
          let(:page) { Page.new(updater: user) }

          it "returns unknown" do
            expect(page.updater_name).to eq('unknown')
          end
        end

        describe '#locker_name' do
          let(:page) { Page.new(locker: user) }

          it "returns unknown" do
            expect(page.locker_name).to eq('unknown')
          end
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
        let(:published_at) { 3.days.ago }
        let(:page)         { build_stubbed(:alchemy_page, published_at: published_at) }

        it "returns the published_at value from database" do
          expect(page.published_at).to be_within(1.second).of(published_at)
        end
      end

      context 'with published_at is nil' do
        let(:updated_at) { 3.days.ago }
        let(:page)       { build_stubbed(:alchemy_page, published_at: nil, updated_at: updated_at) }

        it "returns the updated_at value" do
          expect(page.published_at).to be_within(1.second).of(updated_at)
        end
      end
    end

    describe "#richtext_contents_ids" do
      let!(:page) { create(:alchemy_page) }

      let!(:expanded_element) do
        create :alchemy_element, :with_contents,
          name: 'article',
          page: page,
          folded: false
      end

      let!(:folded_element) do
        create :alchemy_element, :with_contents,
          name: 'article',
          page: page,
          folded: true
      end

      subject(:richtext_contents_ids) { page.richtext_contents_ids }

      it 'returns content ids for all expanded elements that have tinymce enabled' do
        expanded_rtf_contents = expanded_element.contents.essence_richtexts
        expect(richtext_contents_ids).to eq(expanded_rtf_contents.pluck(:id))
        folded_rtf_content = folded_element.contents.essence_richtexts.first
        expect(richtext_contents_ids).to_not include(folded_rtf_content.id)
      end

      context 'with nested elements' do
        let!(:nested_expanded_element) do
          create :alchemy_element, :with_contents,
            name: 'article',
            page: page,
            parent_element: expanded_element,
            folded: false
        end

        let!(:nested_folded_element) do
          create :alchemy_element, :with_contents,
            name: 'article',
            page: page,
            parent_element: folded_element,
            folded: true
        end

        it 'returns content ids for all expanded nested elements that have tinymce enabled' do
          expanded_rtf_contents = expanded_element.contents.essence_richtexts
          nested_expanded_rtf_contents = nested_expanded_element.contents.essence_richtexts
          rtf_content_ids = expanded_rtf_contents.pluck(:id) +
            nested_expanded_rtf_contents.pluck(:id)
          expect(richtext_contents_ids.sort).to eq(rtf_content_ids)

          nested_folded_rtf_content = nested_folded_element.contents.essence_richtexts.first

          expect(richtext_contents_ids).to_not include(nested_folded_rtf_content.id)
        end
      end
    end

    describe '#fixed_attributes' do
      let(:page) { Alchemy::Page.new }

      it 'holds an instance of FixedAttributes' do
        expect(page.fixed_attributes).to be_a(Alchemy::Page::FixedAttributes)
      end
    end

    describe '#attribute_fixed?' do
      let(:page) { Alchemy::Page.new }

      it 'delegates to instance of FixedAttributes' do
        expect_any_instance_of(Alchemy::Page::FixedAttributes).to receive(:fixed?).with('yolo')
        page.attribute_fixed?('yolo')
      end
    end

    describe '#set_fixed_attributes' do
      context 'when fixed attributes are defined' do
        let(:page) { create(:alchemy_page, page_layout: 'readonly') }

        it 'sets them before each save' do
          expect {
            page.update(name: 'Foo')
          }.to_not change { page.name }
        end
      end
    end

    describe '#attach_to_menu!' do
      let(:page) { create(:alchemy_page) }

      context 'if menu_id is set' do
        let(:root_node) { create(:alchemy_node) }

        before do
          page.menu_id = root_node.id
        end

        context 'and no nodes are present yet' do
          it 'attaches to menu' do
            expect { page.save }.to change { page.nodes.count }.from(0).to(1)
          end
        end

        context 'and nodes are already present' do
          let!(:page_node) { create(:alchemy_node, page: page) }

          it 'does not attach to menu' do
            expect { page.save }.not_to change { page.nodes.count }
          end
        end
      end

      context 'if menu_id is not set' do
        it 'does not attach to menu' do
          expect { page.save }.not_to change { page.nodes.count }
        end
      end

      context 'if menu_id is empty' do
        it 'does not raise error' do
          page.menu_id = ""
          expect { page.save }.not_to raise_error
        end
      end
    end

    describe '#nodes' do
      let(:page) { create(:alchemy_page) }
      let(:node) { create(:alchemy_node, page: page, updated_at: 1.hour.ago) }

      it 'returns all nodes the page is attached to' do
        expect(page.nodes).to include(node)
      end

      describe 'after page updates' do
        it 'touches all nodes' do
          expect {
            page.update(name: 'foo')
          }.to change { node.reload.updated_at }
        end
      end
    end

    describe '#menus' do
      let(:page) { create(:alchemy_page) }
      let(:root_node) { create(:alchemy_node) }

      let!(:child_node) do
        create(:alchemy_node, page: page, parent: root_node)
      end

      it 'returns all root nodes the page is attached to' do
        expect(page.menus).to include(root_node)
      end
    end
  end
end
