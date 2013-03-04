# encoding: UTF-8

require 'spec_helper'

module Alchemy
  describe Page do

    let(:rootpage)      { Page.root }
    let(:language)      { Language.get_default }
    let(:klingonian)    { FactoryGirl.create(:klingonian) }
    let(:language_root) { FactoryGirl.create(:language_root_page) }
    let(:page)          { mock(:page, :page_layout => 'foo') }
    let(:public_page)   { FactoryGirl.create(:public_page) }
    let(:news_page)     { FactoryGirl.create(:public_page, :page_layout => 'news', :do_not_autogenerate => false) }

    describe ".layout_description" do

      context "for a language root page" do

        it "should return the page layout description as hash" do
          language_root.layout_description['name'].should == 'intro'
        end

        it "should return an empty hash for root page" do
          rootpage.layout_description.should == {}
        end

      end

      it "should raise Exception if the page_layout could not be found in the definition file" do
        expect { page.layout_description }.to raise_error
      end

    end

    it "should contain one rootpage" do
      Page.rootpage.should be_instance_of(Page)
    end

    it "should return all rss feed elements" do
      news_page.feed_elements.should_not be_empty
      news_page.feed_elements.should == Element.find_all_by_name('news')
    end

    context "finding elements" do

      before do
        FactoryGirl.create(:element, :public => false, :page => public_page)
        FactoryGirl.create(:element, :public => false, :page => public_page)
      end

      it "should return the collection of elements if passed an array into options[:collection]" do
        options = {:collection => public_page.elements}
        public_page.find_elements(options).all.should == public_page.elements.all
      end

      context "with show_non_public argument TRUE" do

        it "should return all elements from empty options" do
          public_page.find_elements({}, true).all.should == public_page.elements.all
        end

        it "should only return the elements passed as options[:only]" do
          public_page.find_elements({:only => ['article']}, true).all.should == public_page.elements.named('article').all
        end

        it "should not return the elements passed as options[:except]" do
          public_page.find_elements({:except => ['article']}, true).all.should == public_page.elements - public_page.elements.named('article').all
        end

        it "should return elements offsetted" do
          public_page.find_elements({:offset => 2}, true).all.should == public_page.elements.offset(2)
        end

        it "should return elements limitted in count" do
          public_page.find_elements({:count => 1}, true).all.should == public_page.elements.limit(1)
        end

      end

      context "with show_non_public argument FALSE" do

        it "should return all elements from empty arguments" do
          public_page.find_elements().all.should == public_page.elements.published.all
        end

        it "should only return the public elements passed as options[:only]" do
          public_page.find_elements(:only => ['article']).all.should == public_page.elements.published.named('article').all
        end

        it "should return all public elements except the ones passed as options[:except]" do
          public_page.find_elements(:except => ['article']).all.should == public_page.elements.published.all - public_page.elements.published.named('article').all
        end

        it "should return elements offsetted" do
          public_page.find_elements({:offset => 2}).all.should == public_page.elements.published.offset(2)
        end

        it "should return elements limitted in count" do
          public_page.find_elements({:count => 1}).all.should == public_page.elements.published.limit(1)
        end

      end

    end

    describe '#create' do

      context "before/after filter" do

        it "should automatically set the title from its name" do
          page = FactoryGirl.create(:page, :name => 'My Testpage', :language => language, :parent_id => language_root.id)
          page.title.should == 'My Testpage'
        end

        it "should get a webfriendly urlname" do
          page = FactoryGirl.create(:page, :name => 'klingon$&stößel ', :language => language, :parent_id => language_root.id)
          page.urlname.should == 'klingon-stoessel'
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
          page.class.stamper_class.to_s.should == 'Alchemy::User'
        end

      end

    end

    describe '#update' do

      let(:page) { FactoryGirl.create(:page, :name => 'My Testpage', :language => language, :parent_id => language_root.id) }

      context "before/after filter" do

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

        end

        context "urlname has not changed" do

          it "should not store a legacy url" do
            page.urlname = 'my-testpage'
            page.save!
            page.legacy_urls.should be_empty
          end

        end

      end

    end

    describe "#destroy" do

      context "with trashed but still assigned elements" do

        before do
          news_page.elements.map(&:trash)
        end

        it "should not delete the trashed elements" do
          news_page.destroy
          Element.trashed.should_not be_empty
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

    context ".contentpages" do

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

    context ".public" do

      it "should return pages that are public" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        FactoryGirl.create(:public_page, :name => 'Second Public Child', :parent_id => language_root.id, :language => language)
        Page.published.should have(3).pages
      end

    end

    context ".not_locked" do

      it "should return pages that are not blocked by a user at the moment" do
        FactoryGirl.create(:public_page, :locked => true, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        FactoryGirl.create(:public_page, :name => 'Second Public Child', :parent_id => language_root.id, :language => language)
        Page.not_locked.should have(3).pages
      end
    end

    context ".all_locked" do
      it "should return 1 page that is blocked by a user at the moment" do
        FactoryGirl.create(:public_page, :locked => true, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        Page.all_locked.should have(1).pages
      end
    end

    context ".language_roots" do
      it "should return 1 language_root" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :parent_id => language_root.id, :language => language)
        Page.language_roots.should have(1).pages
      end
    end


    context ".layoutpages" do
      it "should return 1 layoutpage" do
        FactoryGirl.create(:public_page, :layoutpage => true, :name => 'Layoutpage', :parent_id => rootpage.id, :language => language)
        Page.layoutpages.should have(1).pages
      end
    end

    context ".visible" do
      it "should return 1 visible page" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :visible => true, :parent_id => language_root.id, :language => language)
        Page.visible.should have(1).pages
      end
    end

    context ".not_restricted" do
      it "should return 2 accessible pages" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => language_root.id, :language => language)
        Page.not_restricted.should have(2).pages
      end
    end

    context ".restricted" do
      it "should return 1 restricted page" do
        FactoryGirl.create(:public_page, :name => 'First Public Child', :restricted => true, :parent_id => language_root.id, :language => language)
        Page.restricted.should have(1).pages
      end
    end

    context "#unlock" do
      it "should set the locked status to false" do
        page = FactoryGirl.create(:public_page, :locked => true)
        page.unlock
        page.locked.should == false
      end
    end

    describe "#cell_definitions" do

      before do
        @page = FactoryGirl.build(:page, :page_layout => 'foo')
        @page.stub!(:layout_description).and_return({'name' => "foo", 'cells' => ["foo_cell"]})
        @cell_descriptions = [{'name' => "foo_cell", 'elements' => ["1", "2"]}]
        Cell.stub!(:definitions).and_return(@cell_descriptions)
      end

      it "should return all cell definitions for its page_layout" do
        @page.cell_definitions.should == @cell_descriptions
      end

      it "should return empty array if no cells defined in page layout" do
        @page.stub!(:layout_description).and_return({'name' => "foo"})
        @page.cell_definitions.should == []
      end

    end

    describe "#elements_grouped_by_cells" do

      before do
        PageLayout.stub(:get).and_return({
          'name' => 'standard',
          'cells' => ['header'],
          'elements' => ['header', 'text'],
          'autogenerate' => ['header', 'text']
        })
        Cell.stub!(:definitions).and_return([{
          'name' => "header",
          'elements' => ["header"]
        }])
        @page = FactoryGirl.create(:public_page, :do_not_autogenerate => false)
      end

      it "should return elements grouped by cell" do
        @page.elements_grouped_by_cells.keys.first.should be_instance_of(Cell)
        @page.elements_grouped_by_cells.values.first.first.should be_instance_of(Element)
      end

      it "should only include elements beeing in a cell " do
        @page.elements_grouped_by_cells.keys.should_not include(nil)
      end

    end

    describe '.all_from_clipboard_for_select' do

      context "with clipboard holding pages having non unique page layout" do

        it "should return the pages" do
          page_1 = FactoryGirl.create(:page, :language => language)
          page_2 = FactoryGirl.create(:page, :language => language, :name => 'Another page')
          clipboard = [
            {:id => page_1.id, :action => "copy"},
            {:id => page_2.id, :action => "copy"}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should include(page_1, page_2)
        end

      end

      context "with clipboard holding a page having unique page layout" do

        it "should not return any pages" do
          page_1 = FactoryGirl.create(:page, :language => language, :page_layout => 'contact')
          clipboard = [
            {:id => page_1.id, :action => "copy"}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should == []
        end

      end

      context "with clipboard holding two pages. One having a unique page layout." do

        it "should return one page" do
          page_1 = FactoryGirl.create(:page, :language => language, :page_layout => 'standard')
          page_2 = FactoryGirl.create(:page, :name => 'Another page', :language => language, :page_layout => 'contact')
          clipboard = [
            {:id => page_1.id, :action => "copy"},
            {:id => page_2.id, :action => "copy"}
          ]
          Page.all_from_clipboard_for_select(clipboard, language.id).should == [page_1]
        end

      end

    end

    describe "validations" do

      context "saving a normal content page" do

        it "should be possible to save when its urlname already exists in the scope of global pages" do
          contentpage = FactoryGirl.create(:page, :urlname => "existing_twice")
          global_with_same_urlname = FactoryGirl.create(:page, :urlname => "existing_twice", :layoutpage => true)
          contentpage.title = "new Title"
          contentpage.save.should == true
        end

      end

      context "creating a normal content page" do

        before do
          @contentpage = FactoryGirl.build(:page)
        end

        it "should validate the page_layout" do
          @contentpage.page_layout = nil
          @contentpage.save
          @contentpage.should have(1).error_on(:page_layout)
        end

        it "should validate the parent_id" do
          @contentpage.parent_id = nil
          @contentpage.save
          @contentpage.should have(1).error_on(:parent_id)
        end

      end

      context "creating the rootpage without parent_id and page_layout" do

        before do
          Page.delete_all
          @rootpage = FactoryGirl.build(:page, :parent_id => nil, :page_layout => nil, :name => 'Rootpage')
        end

        it "should be valid" do
          @rootpage.save
          @rootpage.should be_valid
        end

      end

      context "saving a systempage" do

        before do
          @systempage = FactoryGirl.build(:systempage)
        end

        it "should not validate the page_layout" do
          @systempage.save
          @systempage.should be_valid
        end

      end

    end

    describe 'before and after filters' do

      context "a normal page" do

        before do
          @page = FactoryGirl.build(:page, :language_code => nil, :language => klingonian, :do_not_autogenerate => false)
        end

        it "should get the language code for language" do
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
            @page.stub!(:definition).and_return({'name' => 'with_cells', 'cells' => ['header', 'main']})
          end

          it "should have the generated elements in their cells" do
            @page.stub!(:cell_definitions).and_return([{'name' => 'header', 'elements' => ['article']}])
            @page.save
            @page.cells.where(:name => 'header').first.elements.should_not be_empty
          end

          context "and no elements in cell definitions" do

            it "should have the elements in the nil cell" do
              @page.stub!(:cell_definitions).and_return([{'name' => 'header', 'elements' => []}])
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

        let(:news_element) { FactoryGirl.create(:element, :name => 'news') }

        it "all elements not allowed on this page should be trashed" do
          news_page.elements << news_element
          news_page.update_attributes :page_layout => 'standard'
          news_page.elements.trashed.should include(news_element)
        end

        it "should autogenerate elements" do
          news_page.update_attributes :page_layout => 'standard'
          news_page.elements.available.collect(&:name).should include('header')
        end

      end

    end

    describe '#fold' do

      before do
        @user = FactoryGirl.create(:admin_user, :email => 'faz@baz.com', :login => 'foo_baz')
      end

      context "with folded status set to true" do

        it "should create a folded page for user" do
          public_page.fold(@user.id, true)
          FoldedPage.find_or_create_by_user_id_and_page_id(@user.id, public_page.id).should_not be_nil
        end

      end

    end

    describe 'previous and next. ' do

      let(:center_page) { FactoryGirl.create(:public_page, :name => 'Center Page') }
      let(:next_page) { FactoryGirl.create(:public_page, :name => 'Next Page') }

      before do
        public_page
        center_page
        next_page
      end

      describe '#previous' do

        it "should return the previous page on the same level" do
          center_page.previous.should == public_page
        end

        context "no previous page on same level present" do

          it "should return nil" do
            public_page.previous.should be_nil
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

    describe '.copy' do
      let(:page) { FactoryGirl.create(:page, :name => 'Source') }
      subject { Page.copy(page) }

      it "the copy should have added (copy) to name" do
        subject.name.should == "#{page.name} (Copy)"
      end

      context "page with tags" do
        before { page.tag_list = 'red, yellow'; page.save }

        it "the copy should have source tag_list" do
          subject.tag_list.should_not be_empty
          subject.tag_list.should == page.tag_list
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
          page.elements.first.trash
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
          page.stub!(:definition).and_return({'name' => 'standard', 'elements' => ['headline'], 'autogenerate' => ['headline']})
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

    describe "#cache_key" do
      let(:page) { stub_model(Page) }
      subject { page }
      its(:cache_key) { should match(page.id.to_s) }
    end

    describe "#publish!" do
      let(:page) { stub_model(Page, public: false, name: "page", parent_id: 1, urlname: "page", language: stub_model(Language), page_layout: "bla") }
      before { page.publish! }

      it "sets public attribute to true" do
        page.public.should == true
      end
    end

  end
end
