# encoding: UTF-8

require 'spec_helper'

module Alchemy
  describe Page do

    let(:rootpage)      { Page.root }
    let(:language)      { Language.default }
    let(:klingonian)    { FactoryGirl.create(:klingonian) }
    let(:language_root) { FactoryGirl.create(:language_root_page) }
    let(:page)          { mock_model(Page, :page_layout => 'foo') }
    let(:public_page)   { FactoryGirl.create(:public_page) }
    let(:news_page)     { FactoryGirl.create(:public_page, :page_layout => 'news', :do_not_autogenerate => false) }


    # Validations

    context 'validations' do
      context "Creating a normal content page" do
        let(:contentpage)              { FactoryGirl.build(:page) }
        let(:with_same_urlname)        { FactoryGirl.create(:page, urlname: "existing_twice") }
        let(:global_with_same_urlname) { FactoryGirl.create(:page, urlname: "existing_twice", layoutpage: true) }

        context "when its urlname exists as global page" do
          before { global_with_same_urlname }

          it "it should be possible to save." do
            contentpage.urlname = "existing_twice"
            contentpage.should be_valid
          end
        end

        it "should validate the page_layout" do
          contentpage.page_layout = nil
          contentpage.should_not be_valid
          contentpage.should have(1).error_on(:page_layout)
        end

        it "should validate the parent_id" do
          contentpage.parent_id = nil
          contentpage.should_not be_valid
          contentpage.should have(1).error_on(:parent_id)
        end

        context 'with page having same urlname' do
          before { with_same_urlname }

          it "should not be valid" do
            contentpage.urlname = 'existing_twice'
            contentpage.should_not be_valid
          end
        end

        context "with url_nesting set to true" do
          let(:other_parent) { FactoryGirl.create(:page, parent_id: Page.root.id) }

          before do
            Config.stub(:get).and_return(true)
            with_same_urlname
          end

          it "should only validate urlname dependent of parent" do
            contentpage.urlname = 'existing_twice'
            contentpage.parent_id = other_parent.id
            contentpage.should be_valid
          end

          it "should validate urlname dependent of parent" do
            contentpage.urlname = 'existing_twice'
            contentpage.should_not be_valid
          end
        end
      end

      context "creating the rootpage without parent_id and page_layout" do
        let(:rootpage) { build(:page, parent_id: nil, page_layout: nil, name: 'Rootpage') }

        before do
          Page.delete_all
        end

        it "should be valid" do
          rootpage.should be_valid
        end
      end

      context "saving a systempage" do
        let(:systempage) { build(:systempage) }

        it "should not validate the page_layout" do
          systempage.should be_valid
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
        FactoryGirl.create(:page, :name => 'My Testpage', :language => language, :parent_id => language_root.id)
      end

      context 'before_save' do
        it "should not set the title automatically if the name changed but title is not blank" do
          page.name = "My Renaming Test"
          page.save; page.reload
          page.title.should == "My Testpage"
        end

        it "should not automatically set the title if it changed its value" do
          page.title = "I like SEO"
          page.save; page.reload
          page.title.should == "I like SEO"
        end
      end

      context 'after_update' do
        context "urlname has changed" do
          it "should store legacy url if page is not redirect to external page" do
            page.urlname = 'new-urlname'
            page.save!
            page.legacy_urls.should_not be_empty
            page.legacy_urls.first.urlname.should == 'my-testpage'
          end

          it "should not store legacy url if page is redirect to external page" do
            page.urlname = 'new-urlname'
            page.page_layout = "external"
            page.save!
            page.legacy_urls.should be_empty
          end

          it "should not store legacy url twice for same urlname" do
            page.urlname = 'new-urlname'
            page.save!
            page.urlname = 'my-testpage'
            page.save!
            page.urlname = 'another-urlname'
            page.save!
            page.legacy_urls.select { |u| u.urlname == 'my-testpage' }.size.should == 1
          end
        end

        context "urlname has not changed" do
          it "should not store a legacy url" do
            page.urlname = 'my-testpage'
            page.save!
            page.legacy_urls.should be_empty
          end
        end
      end

      context 'after_move' do
        let(:parent_1) { FactoryGirl.create(:page, name: 'Parent 1', visible: true) }
        let(:parent_2) { FactoryGirl.create(:page, name: 'Parent 2', visible: true) }
        let(:page)     { FactoryGirl.create(:page, parent_id: parent_1.id, name: 'Page', visible: true) }

        it "updates the urlname" do
          page.urlname.should == 'parent-1/page'
          page.move_to_child_of parent_2
          page.urlname.should == 'parent-2/page'
        end

        context 'of an external page' do
          let(:external) { FactoryGirl.create(:page, parent_id: parent_1.id, name: 'external', page_layout: 'external', urlname: 'http://google.com') }

          it "the urlname does not get updated" do
            external.move_to_child_of parent_2
            external.urlname.should == 'http://google.com'
          end
        end
      end

      context "a normal page" do
        before do
          @page = FactoryGirl.build(:page, :language_code => nil, :language => klingonian, :do_not_autogenerate => false)
        end

        it "should set the language code" do
          @page.save
          @page.language_code.should == "kl"
        end

        it "should autogenerate the elements" do
          @page.save
          @page.elements.should_not be_empty
        end

        it "should not autogenerate elements that are already on the page" do
          @page.elements << FactoryGirl.create(:element, :name => 'header')
          @page.save
          @page.elements.select { |e| e.name == 'header' }.length.should == 1
        end

        context "with cells" do
          before do
            @page.stub(:definition).and_return({'name' => 'with_cells', 'cells' => ['header', 'main']})
          end

          it "should have the generated elements in their cells" do
            @page.stub(:cell_definitions).and_return([{'name' => 'header', 'elements' => ['article']}])
            @page.save
            @page.cells.where(:name => 'header').first.elements.should_not be_empty
          end

          context "and no elements in cell definitions" do
            it "should have the elements in the nil cell" do
              @page.stub(:cell_definitions).and_return([{'name' => 'header', 'elements' => []}])
              @page.save
              @page.cells.collect(&:elements).flatten.should be_empty
            end
          end
        end

        context "with children getting restricted set to true" do
          before do
            @page.save
            @child1 = FactoryGirl.create(:page, :name => 'Child 1', :parent_id => @page.id)
            @page.reload
            @page.restricted = true
            @page.save
          end

          it "should restrict all its children" do
            @child1.reload
            @child1.restricted?.should be_true
          end
        end

        context "with restricted parent gets created" do
          before do
            @page.save
            @page.parent.update_attributes(:restricted => true)
            @new_page = FactoryGirl.create(:page, :name => 'New Page', :parent_id => @page.id)
          end

          it "should also be restricted" do
            @new_page.restricted?.should be_true
          end
        end

        context "with do_not_autogenerate set to true" do
          before do
            @page.do_not_autogenerate = true
          end

          it "should not autogenerate the elements" do
            @page.save
            @page.elements.should be_empty
          end
        end
      end

      context "a systempage" do
        before do
          @page = FactoryGirl.create(:systempage)
        end

        it "should not get the language code for language" do
          @page.language_code.should be_nil
        end

        it "should not autogenerate the elements" do
          @page.elements.should be_empty
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
          news_page.elements.pluck(:name).should include('contactform')
        end
      end
    end


    # ClassMethods (a-z)

    describe '.all_from_clipboard_for_select' do
      context "with clipboard holding pages having non unique page layout" do
        it "should return the pages" do
          page_1 = FactoryGirl.create(:page, :language => language)
          page_2 = FactoryGirl.create(:page, :language => language, :name => 'Another page')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should include(page_1, page_2)
        end
      end

      context "with clipboard holding a page having unique page layout" do
        it "should not return any pages" do
          page_1 = FactoryGirl.create(:page, :language => language, :page_layout => 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should == []
        end
      end

      context "with clipboard holding two pages. One having a unique page layout." do
        it "should return one page" do
          page_1 = FactoryGirl.create(:page, :language => language, :page_layout => 'standard')
          page_2 = FactoryGirl.create(:page, :name => 'Another page', :language => language, :page_layout => 'contact')
          clipboard = [
            {'id' => page_1.id.to_s, 'action' => 'copy'},
            {'id' => page_2.id.to_s, 'action' => 'copy'}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should == [page_1]
        end
      end
    end

    describe '.all_locked' do
      it "should return 1 page that is blocked by a user at the moment" do
        FactoryGirl.create(:public_page, :locked => true, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        Page.all_locked.should have(1).pages
      end
    end

    describe '.contentpages' do
      before do
        layoutroot = Page.find_or_create_layout_root_for(klingonian.id)
        @layoutpage = FactoryGirl.create(:public_page, :name => 'layoutpage', :layoutpage => true, :parent_id => layoutroot.id, :language => klingonian)
        @klingonian_lang_root = FactoryGirl.create(:language_root_page, :name => 'klingonian_lang_root', :layoutpage => nil, :language => klingonian)
        @contentpage = FactoryGirl.create(:public_page, :name => 'contentpage', :parent_id => language_root.id, :language => language)
      end

      it "should return a collection of contentpages" do
        Page.contentpages.to_a.should include(language_root, @klingonian_lang_root, @contentpage)
      end

      it "should not contain pages with attribute :layoutpage set to true" do
        Page.contentpages.to_a.select { |p| p.layoutpage == true }.should be_empty
      end

      it "should contain pages with attribute :layoutpage set to nil" do
        Page.contentpages.to_a.select { |p| p.layoutpage == nil }.should include(@klingonian_lang_root)
      end
    end

    describe '.copy' do
      let(:page) { FactoryGirl.create(:page, :name => 'Source') }
      subject { Page.copy(page) }

      it "the copy should have added (copy) to name" do
        subject.name.should == "#{page.name} (Copy)"
      end

      context "page with tags" do
        before { page.tag_list = 'red, yellow'; page.save }

        it "the copy should have source tag_list" do
          # The order of tags varies between postgresql and sqlite/mysql
          # This is related to acts-as-taggable-on v.2.4.1
          # To fix the spec we sort the tags until the issue is solved (https://github.com/mbleigh/acts-as-taggable-on/issues/363)
          subject.tag_list.should_not be_empty
          subject.tag_list.sort.should == page.tag_list.sort
        end
      end

      context "page with elements" do
        before { page.elements << FactoryGirl.create(:element) }

        it "the copy should have source elements" do
          subject.elements.should_not be_empty
          subject.elements.count.should == page.elements.count
        end
      end

      context "page with trashed elements" do
        before do
          page.elements << FactoryGirl.create(:element)
          page.elements.first.trash!
        end

        it "the copy should not hold a copy of the trashed elements" do
          subject.elements.should be_empty
        end
      end

      context "page with cells" do
        before { page.cells << FactoryGirl.create(:cell) }

        it "the copy should have source cells" do
          subject.cells.should_not be_empty
          subject.cells.count.should == page.cells.length # It must be length, because!
        end
      end

      context "page with autogenerate elements" do
        before do
          page = FactoryGirl.create(:page)
          page.stub(:definition).and_return({'name' => 'standard', 'elements' => ['headline'], 'autogenerate' => ['headline']})
        end

        it "the copy should not autogenerate elements" do
          subject.elements.should be_empty
        end
      end

      context "with different page name given" do
        subject { Page.copy(page, {:name => 'Different name'}) }
        it "should take this name" do
          subject.name.should == 'Different name'
        end
      end
    end

    describe '.create' do
      context "before/after filter" do
        it "should automatically set the title from its name" do
          page = FactoryGirl.create(:page, :name => 'My Testpage', :language => language, :parent_id => language_root.id)
          page.title.should == 'My Testpage'
        end

        it "should get a webfriendly urlname" do
          page = FactoryGirl.create(:page, :name => 'klingon$&stößel ', :language => language, :parent_id => language_root.id)
          page.urlname.should == 'klingon-stoessel'
        end

        context "with no name set" do
          it "should not set a urlname" do
            page = Page.create(name: '', language: language, parent_id: language_root.id)
            expect(page.urlname).to be_blank
          end
        end

        it "should generate a three letter urlname from two letter name" do
          page = FactoryGirl.create(:page, :name => 'Au', :language => language, :parent_id => language_root.id)
          page.urlname.should == '-au'
        end

        it "should generate a three letter urlname from two letter name with umlaut" do
          page = FactoryGirl.create(:page, :name => 'Aü', :language => language, :parent_id => language_root.id)
          page.urlname.should == 'aue'
        end

        it "should generate a three letter urlname from one letter name" do
          page = FactoryGirl.create(:page, :name => 'A', :language => language, :parent_id => language_root.id)
          page.urlname.should == '--a'
        end

        it "should add a user stamper" do
          page = FactoryGirl.create(:page, :name => 'A', :language => language, :parent_id => language_root.id)
          page.class.stamper_class.to_s.should == 'DummyUser'
        end

        context "with language given" do
          it "does not set the language from parent" do
            Page.any_instance.should_not_receive(:set_language_from_parent_or_default)
            Page.create!(name: 'A', parent_id: language_root.id, page_layout: 'standard', language: language)
          end
        end

        context "with no language given" do
          it "sets the language from parent" do
            Page.any_instance.should_receive(:set_language_from_parent_or_default)
            Page.create!(name: 'A', parent_id: language_root.id, page_layout: 'standard')
          end
        end
      end
    end

    describe '.find_or_create_layout_root_for' do
      subject { Page.find_or_create_layout_root_for(language_id) }

      let(:language)    { mock_model('Language', name: 'English') }
      let(:language_id) { language.id }

      before { Language.stub(:find).and_return(language) }

      context 'if no layout root page for given language id could be found' do
        before do
          Page.should_receive(:create!).and_return(page)
        end

        it "creates one" do
          should eq(page)
        end
      end

      context 'if layout root page for given language id could be found' do
        let(:page) { mock_model('Page') }

        before do
          Page.should_receive(:layout_root_for).and_return(page)
        end

        it "returns layout root page" do
          should eq(page)
        end
      end
    end

    describe '.language_roots' do
      it "should return 1 language_root" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        Page.language_roots.should have(1).pages
      end
    end

    describe '.layout_description' do
      it "should raise Exception if the page_layout could not be found in the definition file" do
        expect { page.layout_description }.to raise_error
      end

      context "for a language root page" do
        it "should return the page layout description as hash" do
          language_root.layout_description['name'].should == 'intro'
        end

        it "should return an empty hash for root page" do
          rootpage.layout_description.should == {}
        end
      end
    end

    describe '.layoutpages' do
      it "should return 1 layoutpage" do
        FactoryGirl.create(:public_page, :layoutpage => true, :name => 'Layoutpage', :parent_id => rootpage.id, :language => language)
        Page.layoutpages.should have(1).pages
      end
    end

    describe '.not_locked' do
      it "should return pages that are not blocked by a user at the moment" do
        FactoryGirl.create(:public_page, :locked => true, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        FactoryGirl.create(:public_page, :name => 'Second Public Child', :parent_id => language_root.id, :language => language)
        Page.not_locked.should have(3).pages
      end
    end

    describe '.not_restricted' do
      it "should return 2 accessible pages" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => language_root.id, :language => language)
        Page.not_restricted.should have(2).pages
      end
    end

    describe '.public' do
      it "should return pages that are public" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        FactoryGirl.create(:public_page, :name => 'Second Public Child', :parent_id => language_root.id, :language => language)
        Page.published.should have(3).pages
      end
    end

    describe '.restricted' do
      it "should return 1 restricted page" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => language_root.id, :language => language)
        Page.restricted.should have(1).pages
      end
    end

    describe '.rootpage' do
      it "should contain one rootpage" do
        Page.rootpage.should be_instance_of(Page)
      end
    end

    describe '.visible' do
      it "should return 1 visible page" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :visible => true, :parent_id => language_root.id, :language => language)
        Page.visible.should have(1).pages
      end
    end


    # InstanceMethods (a-z)

    describe '#available_element_definitions' do
      let(:page) { FactoryGirl.build_stubbed(:public_page) }

      it "returns all element definitions of available elements" do
        page.available_element_definitions.should be_an(Array)
        page.available_element_definitions.collect { |e| e['name'] }.should include('header')
      end

      context "with unique elements already on page" do
        let(:element) { FactoryGirl.build_stubbed(:unique_element) }
        before { page.stub_chain(:elements, :not_trashed, :pluck).and_return([element.name]) }

        it "does not return unique element definitions" do
          page.available_element_definitions.collect { |e| e['name'] }.should include('article')
          page.available_element_definitions.collect { |e| e['name'] }.should_not include('header')
        end
      end

      context "for page_layout not existing" do
        let(:page) { FactoryGirl.build_stubbed(:page, page_layout: 'not_existing_one') }

        it "should raise error" do
          expect {
            page.available_element_definitions
          }.to raise_error(Alchemy::PageLayoutDefinitionError)
        end
      end

      context 'limited amount' do
        let(:page) { FactoryGirl.build_stubbed(:page, page_layout: 'columns') }
        let(:unique_element) { FactoryGirl.build_stubbed(:unique_element, name: 'unique_headline') }
        let(:element_1) { FactoryGirl.build_stubbed(:element, name: 'column_headline') }
        let(:element_2) { FactoryGirl.build_stubbed(:element, name: 'column_headline') }
        let(:element_3) { FactoryGirl.build_stubbed(:element, name: 'column_headline') }

        before {
          Element.stub(:definitions).and_return([
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
          PageLayout.stub(:get).and_return({
            'name' => 'columns',
            'elements' => ['column_headline', 'unique_headline'],
            'autogenerate' => ['unique_headline', 'column_headline', 'column_headline', 'column_headline']
          })
          page.stub_chain(:elements, :not_trashed, :pluck).and_return([unique_element.name, element_1.name, element_2.name, element_3.name])
        }

        it "should be readable" do
          element = page.element_definitions_by_name('column_headline').first
          element['amount'].should be 3
        end

        it "should limit elements" do
          page.available_element_definitions.collect { |e| e['name'] }.should_not include('column_headline')
        end

        it "should be ignored if unique" do
          page.available_element_definitions.collect { |e| e['name'] }.should_not include('unique_headline')
        end
      end
    end

    describe '#available_element_names' do
      let(:page) { FactoryGirl.build_stubbed(:page) }

      it "returns all names of elements that could be placed on current page" do
        page.available_element_names == %w(header article)
      end
    end

    describe '#cache_key' do
      let(:page) { stub_model(Page) }
      subject { page }
      its(:cache_key) { should match(page.id.to_s) }
    end

    describe '#cell_definitions' do
      before do
        @page = FactoryGirl.build(:page, :page_layout => 'foo')
        @page.stub(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"]})
        @cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
        Cell.stub(:definitions).and_return(@cell_descriptions)
      end

      it "should return all cell definitions for its page_layout" do
        @page.cell_definitions.should == @cell_descriptions
      end

      it "should return empty array if no cells defined in page layout" do
        @page.stub(:layout_description).and_return({'name' => "foo"})
        @page.cell_definitions.should == []
      end
    end

    describe '#destroy' do
      context "with trashed but still assigned elements" do
        before { news_page.elements.map(&:trash!) }

        it "should not delete the trashed elements" do
          news_page.destroy
          Element.trashed.should_not be_empty
        end
      end
    end

    describe '#element_definitions' do
      let(:page) { FactoryGirl.build_stubbed(:page) }
      subject { page.element_definitions }
      before { Element.should_receive(:definitions).and_return([{'name' => 'article'}, {'name' => 'header'}]) }

      it "returns all element definitions that could be placed on current page" do
        should include({'name' => 'article'})
        should include({'name' => 'header'})
      end
    end

    describe '#element_definitions' do
      let(:page) { FactoryGirl.build_stubbed(:page) }
      subject { page.element_definitions }
      before { Element.should_receive(:definitions).and_return([{'name' => 'article'}, {'name' => 'header'}]) }

      it "returns all element definitions that could be placed on current page" do
        should include({'name' => 'article'})
        should include({'name' => 'header'})
      end
    end

    describe '#element_definitions_by_name' do
      let(:page) { FactoryGirl.build_stubbed(:public_page) }

      context "with no name given" do
        it "returns empty array" do
          page.element_definitions_by_name(nil).should == []
        end
      end

      context "with 'all' passed as name" do
        it "returns all element definitions" do
          Element.should_receive(:definitions)
          page.element_definitions_by_name('all')
        end
      end

      context "with :all passed as name" do
        it "returns all element definitions" do
          Element.should_receive(:definitions)
          page.element_definitions_by_name(:all)
        end
      end
    end

    describe '#element_definition_names' do
      let(:page) { FactoryGirl.build_stubbed(:public_page) }

      it "returns all element names defined in page layout" do
        page.element_definition_names.should == %w(article header)
      end

      it "returns always an array" do
        page.stub(:definition).and_return({})
        page.element_definition_names.should be_an(Array)
      end
    end

    describe '#elements_grouped_by_cells' do
      let(:page) { FactoryGirl.create(:public_page, :do_not_autogenerate => false) }

      before do
        PageLayout.stub(:get).and_return({
          'name' => 'standard',
          'cells' => ['header'],
          'elements' => ['header', 'text'],
          'autogenerate' => ['header', 'text']
        })
        Cell.stub(:definitions).and_return([{
          'name' => "header",
          'elements' => ["header"]
        }])
      end

      it "should return elements grouped by cell" do
        elements = page.elements_grouped_by_cells
        elements.keys.first.should be_instance_of(Cell)
        elements.values.first.first.should be_instance_of(Element)
      end

      it "should only include elements beeing in a cell " do
        page.elements_grouped_by_cells.keys.should_not include(nil)
      end
    end

    describe '#feed_elements' do
      it "should return all rss feed elements" do
        news_page.feed_elements.should_not be_empty
        news_page.feed_elements.should == Element.where(name: 'news').to_a
      end
    end

    describe '#find_elements' do
      before do
        FactoryGirl.create(:element, :public => false, :page => public_page)
        FactoryGirl.create(:element, :public => false, :page => public_page)
      end

      context "with show_non_public argument TRUE" do
        it "should return all elements from empty options" do
          public_page.find_elements({}, true).to_a.should == public_page.elements.to_a
        end

        it "should only return the elements passed as options[:only]" do
          public_page.find_elements({:only => ['article']}, true).to_a.should == public_page.elements.named('article').to_a
        end

        it "should not return the elements passed as options[:except]" do
          public_page.find_elements({:except => ['article']}, true).to_a.should == public_page.elements - public_page.elements.named('article').to_a
        end

        it "should return elements offsetted" do
          public_page.find_elements({:offset => 2}, true).to_a.should == public_page.elements.offset(2)
        end

        it "should return elements limitted in count" do
          public_page.find_elements({:count => 1}, true).to_a.should == public_page.elements.limit(1)
        end
      end

      context "with options[:from_cell]" do
        let(:element) { FactoryGirl.build_stubbed(:element) }

        context "given as String" do
          context '' do
            before {
              public_page.cells.stub_chain(:find_by_name, :elements, :offset, :limit, :published).and_return([element])
            }

            it "returns only the elements from given cell" do
              public_page.find_elements(from_cell: 'A Cell').to_a.should == [element]
            end
          end

          context "that can not be found" do
            let(:elements) {[]}
            before {
              elements.stub_chain(:offset, :limit, :published).and_return([])
            }

            it "returns empty set" do
              Element.should_receive(:none).and_return(elements)
              public_page.find_elements(from_cell: 'Lolo').to_a.should == []
            end

            it "loggs a warning" do
              Rails.logger.should_receive(:debug)
              public_page.find_elements(from_cell: 'Lolo')
            end
          end
        end

        context "given as cell object" do
          let(:cell) { FactoryGirl.build_stubbed(:cell, page: public_page) }

          it "returns only the elements from given cell" do
            cell.stub_chain(:elements, :offset, :limit, :published).and_return([element])
            public_page.find_elements(from_cell: cell).to_a.should == [element]
          end
        end
      end

      context "with show_non_public argument FALSE" do
        it "should return all elements from empty arguments" do
          public_page.find_elements().to_a.should == public_page.elements.published.to_a
        end

        it "should only return the public elements passed as options[:only]" do
          public_page.find_elements(:only => ['article']).to_a.should == public_page.elements.published.named('article').to_a
        end

        it "should return all public elements except the ones passed as options[:except]" do
          public_page.find_elements(:except => ['article']).to_a.should == public_page.elements.published.to_a - public_page.elements.published.named('article').to_a
        end

        it "should return elements offsetted" do
          public_page.find_elements({:offset => 2}).to_a.should == public_page.elements.published.offset(2)
        end

        it "should return elements limitted in count" do
          public_page.find_elements({:count => 1}).to_a.should == public_page.elements.published.limit(1)
        end
      end
    end

    describe '#first_public_child' do
      before do
        FactoryGirl.create(:page, :name => "First child", :language => language, :public => false, :parent_id => language_root.id)
      end

      it "should return first_public_child" do
        first_public_child = FactoryGirl.create(:public_page, :name => "First public child", :language => language, :parent_id => language_root.id)
        language_root.first_public_child.should == first_public_child
      end

      it "should return nil if no public child exists" do
        language_root.first_public_child.should == nil
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
            Alchemy.user_class.should_receive(:'<').and_return(true)
          end

          context 'if page is folded' do
            before do
              page.stub_chain(:folded_pages, :where, :any?).and_return(true)
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
      subject { public_page.get_language_root }

      it "returns the language root page" do
        should eq language_root
      end
    end

    describe '#lock_to!' do
      let(:page) { create(:page) }
      let(:user) { mock_model('DummyUser') }

      it "should set locked to true" do
        page.lock_to!(user)
        page.reload
        page.locked.should == true
      end

      it "should not update the timestamps " do
        expect { page.lock!(user) }.to_not change(page, :updated_at)
      end

      it "should set locked_by to the users id" do
        page.lock_to!(user)
        page.reload
        page.locked_by.should == user.id
      end
    end

    describe '#copy_and_paste' do
      let(:source) { FactoryGirl.build_stubbed(:page) }
      let(:new_parent) { FactoryGirl.build_stubbed(:page) }
      let(:page_name) { "Pagename (pasted)" }
      let(:copied_page) { mock_model('Page') }

      subject { Page.copy_and_paste(source, new_parent, page_name) }

      it "should copy the source page with the given name to the new parent" do
        Page.should_receive(:copy).with(source, {
          parent_id: new_parent.id,
          language: new_parent.language,
          name: page_name,
          title: page_name
          })
        subject
      end

      it "should return the copied page" do
        Page.stub(:copy).and_return(copied_page)
        expect(subject).to be_a(copied_page.class)
      end

      context "if source page has children" do
        it "should also copy and paste the children" do
          Page.stub(:copy).and_return(copied_page)
          source.stub(:children).and_return([mock_model('Page')])
          source.should_receive(:copy_children_to).with(copied_page)
          subject
        end
      end
    end

    context 'previous and next.' do
      let(:center_page)     { FactoryGirl.create(:public_page, name: 'Center Page') }
      let(:next_page)       { FactoryGirl.create(:public_page, name: 'Next Page') }
      let(:non_public_page) { FactoryGirl.create(:page, name: 'Not public Page') }
      let(:restricted_page) { FactoryGirl.create(:restricted_page, public: true) }

      before do
        public_page
        restricted_page
        non_public_page
        center_page
        next_page
      end

      describe '#previous' do
        it "should return the previous page on the same level" do
          center_page.previous.should == public_page
          next_page.previous.should == center_page
        end

        context "no previous page on same level present" do
          it "should return nil" do
            public_page.previous.should be_nil
          end
        end

        context "with options restricted" do
          context "set to true" do
            it "returns previous restricted page" do
              center_page.previous(restricted: true).should == restricted_page
            end
          end

          context "set to false" do
            it "skips restricted page" do
              center_page.previous(restricted: false).should == public_page
            end
          end
        end

        context "with options public" do
          context "set to true" do
            it "returns previous public page" do
              center_page.previous(public: true).should == public_page
            end
          end

          context "set to false" do
            it "skips public page" do
              center_page.previous(public: false).should == non_public_page
            end
          end
        end
      end

      describe '#next' do
        it "should return the next page on the same level" do
          center_page.next.should == next_page
        end

        context "no next page on same level present" do
          it "should return nil" do
            next_page.next.should be_nil
          end
        end
      end
    end

    describe '#publish!' do
      let(:page) { FactoryGirl.build_stubbed(:page, public: false) }
      let(:current_time) { Time.now }

      before do
        current_time
        Time.stub(:now).and_return(current_time)
        page.publish!
      end

      it "sets public attribute to true" do
        page.public.should == true
      end

      it "sets published_at attribute to current time" do
        page.published_at.should == current_time
      end
    end

    describe '#set_language_from_parent_or_default' do
      let(:default_language) { mock_model('Language', code: 'es') }
      let(:page) { Page.new }

      before { page.stub(:parent).and_return(parent) }

      subject { page }

      context "parent has a language" do
        let(:parent) { mock_model('Page', language: default_language, language_id: default_language.id, language_code: default_language.code) }

        before do
          page.send(:set_language_from_parent_or_default)
        end

        its(:language_id) { should eq(parent.language_id) }
      end

      context "parent has no language" do
        let(:parent) { mock_model('Page', language: nil, language_id: nil, language_code: nil) }

        before do
          Language.stub(:default).and_return(default_language)
          page.send(:set_language_from_parent_or_default)
        end

        its(:language_id) { should eq(default_language.id) }
      end
    end

    describe '#taggable?' do
      context "definition has 'taggable' key with true value" do
        it "should return true" do
          page = FactoryGirl.build(:page)
          page.stub(:definition).and_return({'name' => 'standard', 'taggable' => true})
          page.taggable?.should be_true
        end
      end

      context "definition has 'taggable' key with foo value" do
        it "should return false" do
          page = FactoryGirl.build(:page)
          page.stub(:definition).and_return({'name' => 'standard', 'taggable' => 'foo'})
          page.taggable?.should be_false
        end
      end

      context "definition has no 'taggable' key" do
        it "should return false" do
          page = FactoryGirl.build(:page)
          page.stub(:definition).and_return({'name' => 'standard'})
          page.taggable?.should be_false
        end
      end
    end

    describe '#unlock!' do
      let(:page) { FactoryGirl.create(:page, locked: true, locked_by: 1) }

      before do
        page.stub(:save).and_return(true)
      end

      it "should set the locked status to false" do
        page.unlock!
        page.reload
        page.locked.should == false
      end

      it "should not update the timestamps " do
        expect { page.unlock! }.to_not change(page, :updated_at)
      end

      it "should set locked_by to nil" do
        page.unlock!
        page.reload
        page.locked_by.should == nil
      end

      it "sets current preview to nil" do
        Page.current_preview = page
        page.unlock!
        Page.current_preview.should be_nil
      end
    end

    context 'urlname updating' do
      let(:parentparent) { FactoryGirl.create(:page, name: 'parentparent', visible: true) }
      let(:parent)       { FactoryGirl.create(:page, parent_id: parentparent.id, name: 'parent', visible: true) }
      let(:page)         { FactoryGirl.create(:page, parent_id: parent.id, name: 'page', visible: true) }
      let(:invisible)    { FactoryGirl.create(:page, parent_id: page.id, name: 'invisible', visible: false) }
      let(:contact)      { FactoryGirl.create(:page, parent_id: invisible.id, name: 'contact', visible: true) }
      let(:external)     { FactoryGirl.create(:page, parent_id: parent.id, name: 'external', page_layout: 'external', urlname: 'http://google.com') }

      context "with activated url_nesting" do
        before { Config.stub(:get).and_return(true) }

        it "should store all parents urlnames delimited by slash" do
          page.urlname.should == 'parentparent/parent/page'
        end

        it "should not include the root page" do
          page.urlname.should_not =~ /root/
        end

        it "should not include the language root page" do
          page.urlname.should_not =~ /startseite/
        end

        it "should not include invisible pages" do
          contact.urlname.should_not =~ /invisible/
        end

        context "after changing page's urlname" do
          it "updates urlnames of descendants" do
            page
            parentparent.urlname = 'new-urlname'
            parentparent.save!
            page.reload
            page.urlname.should == 'new-urlname/parent/page'
          end

          context 'with descendants that are redirecting to external' do
            it "it skips this page" do
              external
              parent.urlname = 'new-urlname'
              parent.save!
              external.reload
              external.urlname.should == 'http://google.com'
            end
          end

          it "should create a legacy url" do
            page.stub(:slug).and_return('foo')
            page.update_urlname!
            page.legacy_urls.should_not be_empty
            page.legacy_urls.pluck(:urlname).should include('parentparent/parent/page')
          end
        end

        context "after updating my visibility" do
          it "should update urlnames of descendants" do
            page
            parentparent.visible = false
            parentparent.save!
            page.reload
            page.urlname.should == 'parent/page'
          end
        end
      end

      context "with disabled url_nesting" do
        before { Config.stub(:get).and_return(false) }

        it "should only store my urlname" do
          page.urlname.should == 'page'
        end
      end
    end

    describe "#update_node!" do

      let(:original_url) { "sample-url" }
      let(:page) { FactoryGirl.create(:page, :language => language, :parent_id => language_root.id, :urlname => original_url, restricted: false) }
      let(:node) { TreeNode.new(10, 11, 12, 13, "another-url", true) }

      context "when nesting is enabled" do
        before { Alchemy::Config.stub(:get).with(:url_nesting) { true } }

        context "when page is not external" do

          before { page.stub(redirects_to_external?: false)}

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

          before { page.stub(redirects_to_external?: true) }

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
        before { Alchemy::Config.stub(:get).with(:url_nesting) { false } }

        context "when page is not external" do

          before { page.stub(redirects_to_external?: false)}

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

          before { page.stub(redirects_to_external?: true) }

          before { Alchemy::Config.stub(get: true) }

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
        let(:page) { FactoryGirl.build(:page, urlname: 'root/parent/my-name')}

        it "should return the last part of the urlname" do
          page.slug.should == 'my-name'
        end
      end

      context "with single urlname" do
        let(:page) { FactoryGirl.build(:page, urlname: 'my-name')}

        it "should return the last part of the urlname" do
          page.slug.should == 'my-name'
        end
      end

      context "with nil as urlname" do
        let(:page) { FactoryGirl.build(:page, urlname: nil)}

        it "should return nil" do
          page.slug.should be_nil
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
      let(:page) { FactoryGirl.build(:page, public: true, visible: true, restricted: false, locked: false)}

      describe '#status' do
        it "returns a combined status hash" do
          page.status.should == {public: true, visible: true, restricted: false, locked: false}
        end
      end

      describe '#status_title' do
        it "returns a translated status string for public status" do
          page.status_title(:public).should == 'Page is published.'
        end

        it "returns a translated status string for visible status" do
          page.status_title(:visible).should == 'Page is visible in navigation.'
        end

        it "returns a translated status string for locked status" do
          page.status_title(:locked).should == ''
        end

        it "returns a translated status string for restricted status" do
          page.status_title(:restricted).should == 'Page is not restricted.'
        end
      end
    end

    context 'indicate page editors' do
      let(:page) { Page.new }
      let(:user) { create(:editor_user) }

      describe '#creator' do
        before { page.update(creator_id: user.id) }

        it "returns the user that created the page" do
          expect(page.creator).to eq(user)
        end
      end

      describe '#updater' do
        before { page.update(updater_id: user.id) }

        it "returns the user that created the page" do
          expect(page.updater).to eq(user)
        end
      end

      describe '#locker' do
        before { page.update(locked_by: user.id) }

        it "returns the user that created the page" do
          expect(page.locker).to eq(user)
        end
      end

      context 'with user that can not be found' do
        it 'does not raise not found error' do
          %w(creator updater locker).each do |user_type|
            expect {
              page.send(user_type)
            }.to_not raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'with user class having a name accessor' do
        let(:user) { double(name: 'Paul Page') }

        describe '#creator_name' do
          before { page.stub(:creator).and_return(user) }

          it "returns the name of the creator" do
            expect(page.creator_name).to eq('Paul Page')
          end
        end

        describe '#updater_name' do
          before { page.stub(:updater).and_return(user) }

          it "returns the name of the updater" do
            expect(page.updater_name).to eq('Paul Page')
          end
        end

        describe '#locker_name' do
          before { page.stub(:locker).and_return(user) }

          it "returns the name of the current page editor" do
            expect(page.locker_name).to eq('Paul Page')
          end
        end
      end

      context 'with user class not having a name accessor' do
        let(:user) { Alchemy.user_class.new }

        describe '#creator_name' do
          before { page.stub(:creator).and_return(user) }

          it "returns unknown" do
            expect(page.creator_name).to eq('unknown')
          end
        end

        describe '#updater_name' do
          before { page.stub(:updater).and_return(user) }

          it "returns unknown" do
            expect(page.updater_name).to eq('unknown')
          end
        end

        describe '#locker_name' do
          before { page.stub(:locker).and_return(user) }

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
          page.stub(:has_controller?).and_return(true)
          page.stub(:layout_description).and_return({'controller' => 'comments', 'action' => 'index'})
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
