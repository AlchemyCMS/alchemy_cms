require 'ostruct'
require 'spec_helper'

module Alchemy
  describe Admin::PagesController do
    let(:user) { editor_user }
    before { sign_in(user) }

    describe '#index' do
      let(:language_root) { FactoryGirl.build_stubbed(:language_root_page) }

      it "assigns @page_root variable" do
        Page.should_receive(:language_root_for).with(1).and_return(language_root)
        get :index
        assigns(:page_root).should be(language_root)
      end
    end

    describe "#flush" do

      it "should remove the cache of all pages" do
        post :flush, format: :js
        response.status.should == 200
      end

    end

    describe '#new' do
      context "pages in clipboard" do

        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:page) { mock_model(Alchemy::Page, name: 'Foobar') }

        before { clipboard[:pages] = [{id: page.id, action: 'copy'}] }

        it "should load all pages from clipboard" do
          get :new, {page_id: page.id, format: :js}
          assigns(:clipboard_items).should be_kind_of(Array)
        end

      end
    end

    describe '#show' do
      let(:page) { mock_model(Alchemy::Page, language_code: 'nl') }

      before do
        Page.should_receive(:find).with("#{page.id}").and_return(page)
        Page.stub(:language_root_for).and_return(mock_model(Alchemy::Page))
      end

      it "should assign @preview_mode with true" do
        get :show, id: page.id
        expect(assigns(:preview_mode)).to eq(true)
      end

      it "should set the I18n locale to the pages language code" do
        get :show, id: page.id
        expect(::I18n.locale).to eq(:nl)
      end
    end

    describe '#order' do
      let(:page_1)       { FactoryGirl.create(:page, visible: true) }
      let(:page_2)       { FactoryGirl.create(:page, visible: true) }
      let(:page_3)       { FactoryGirl.create(:page, visible: true) }
      let(:page_item_1)  { {id: page_1.id, slug: page_1.slug, restricted: false, external: page_1.redirects_to_external?, visible: page_1.visible?, children: [page_item_2]} }
      let(:page_item_2)  { {id: page_2.id, slug: page_2.slug, restricted: false, external: page_2.redirects_to_external?, visible: page_2.visible?, children: [page_item_3]} }
      let(:page_item_3)  { {id: page_3.id, slug: page_3.slug, restricted: false, external: page_3.redirects_to_external?, visible: page_3.visible? } }
      let(:set_of_pages) { [page_item_1] }

      it "stores the new order" do
        xhr :post, :order, set: set_of_pages.to_json
        page_1.reload
        expect(page_1.descendants).to eq([page_2, page_3])
      end

      context 'with url nesting enabled' do
        before { Alchemy::Config.stub(get: true) }

        it "updates the pages urlnames" do
          xhr :post, :order, set: set_of_pages.to_json
          [page_1, page_2, page_3].map(&:reload)
          expect(page_1.urlname).to eq("#{page_1.slug}")
          expect(page_2.urlname).to eq("#{page_1.slug}/#{page_2.slug}")
          expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
        end

        context 'with invisible page in tree' do
          let(:page_item_2) do
            {
              id: page_2.id,
              slug: page_2.slug,
              children: [page_item_3],
              visible: false
            }
          end

          it "does not use this pages slug in urlnames of descendants" do
            xhr :post, :order, set: set_of_pages.to_json
            [page_1, page_2, page_3].map(&:reload)
            expect(page_1.urlname).to eq("#{page_1.slug}")
            expect(page_2.urlname).to eq("#{page_1.slug}/#{page_2.slug}")
            expect(page_3.urlname).to eq("#{page_1.slug}/#{page_3.slug}")
          end
        end

        context 'with external page in tree' do
          let(:page_item_2) do
            {
              id: page_2.id,
              slug: page_2.slug,
              children: [page_item_3],
              external: true
            }
          end

          it "does not use this pages slug in urlnames of descendants" do
            xhr :post, :order, set: set_of_pages.to_json
            [page_1, page_2, page_3].map(&:reload)
            expect(page_3.urlname).to eq("#{page_1.slug}/#{page_3.slug}")
          end
        end

        context 'with restricted page in tree' do
          let(:page_2) { FactoryGirl.create(:page, restricted: true) }
          let(:page_item_2) do
            {
              id: page_2.id,
              slug: page_2.slug,
              children: [page_item_3],
              restricted: true
            }
          end

          it "updates restricted status of descendants" do
            xhr :post, :order, set: set_of_pages.to_json
            page_3.reload
            expect(page_3.restricted).to be_true
          end
        end

        it "creates legacy urls" do
          xhr :post, :order, set: set_of_pages.to_json
          [page_2, page_3].map(&:reload)
          expect(page_2.legacy_urls.size).to eq(1)
          expect(page_3.legacy_urls.size).to eq(1)
        end
      end
    end

    describe "#configure" do
      render_views

      context "with page having nested urlname" do
        let(:page) { mock_model(Page, {name: 'Foobar', slug: 'foobar', urlname: 'root/parent/foobar', redirects_to_external?: false, layoutpage?: false, taggable?: false}) }

        it "should always show the slug" do
          Page.stub(:find).and_return(page)
          get :configure, {id: page.id, format: :js}
          response.body.should match /value="foobar"/
        end
      end
    end

    describe '#create' do
      let(:language) { mock_model('Language', code: 'kl') }
      let(:parent) { mock_model(Alchemy::Page, language: language) }
      let(:page_params) { {parent_id: parent.id, name: 'new Page'} }

      context "a new page" do
        before do
          Page.any_instance.stub(:set_language_from_parent_or_default_language)
          Page.any_instance.stub(:save).and_return(true)
        end

        it "is nested under given parent" do
          controller.stub(:edit_admin_page_path).and_return('bla')
          post :create, {page: page_params, format: :js}
          expect(assigns(:page).parent_id).to eq(parent.id)
        end

        context "if new page can not be saved" do
          it "should redirect to admin_pages_path" do
            Page.any_instance.stub(:save).and_return(false)
            post :create, page: {}
            response.should redirect_to(admin_pages_path)
          end
        end

        context "with redirect_to in params" do
          let(:page_params) do
            {name: "Foobar", page_layout: 'standard', parent_id: parent.id}
          end

          it "should redirect to given url" do
            post :create, page: page_params, redirect_to: admin_pictures_path
            response.should redirect_to(admin_pictures_path)
          end

          context "but new page can not be saved" do
            it "should redirect to admin_pages_path" do
              Page.any_instance.stub(:save).and_return(false)
              post :create, page: {}, redirect_to: Alchemy.login_path
              response.should redirect_to(admin_pages_path)
            end
          end
        end

        context 'with page redirecting to external' do
          it "redirects to sitemap" do
            Page.any_instance.should_receive(:redirects_to_external?).and_return(true)
            post :create, page: page_params
            response.should redirect_to(admin_pages_path)
          end
        end
      end

      context "with paste_from_clipboard in parameters" do
        let(:page_in_clipboard) { mock_model(Alchemy::Page) }

        before do
          Page.stub!(:find_by_id).with(parent.id).and_return(parent)
          Page.stub!(:find).with(page_in_clipboard.id).and_return(page_in_clipboard)
        end

        it "should call Page#paste_from_clipboard" do
          Page.should_receive(:paste_from_clipboard).with(
            page_in_clipboard,
            parent,
            'pasted Page'
          ).and_return(
            mock_model('Page', save: true, name: 'pasted Page', redirects_to_external?: false)
          )
          post :create, {paste_from_clipboard: page_in_clipboard.id, page: {parent_id: parent.id, name: 'pasted Page'}, format: :js}
        end
      end
    end

    describe '#copy_language_tree' do

      let(:language) { Language.get_default }
      let(:new_language) { FactoryGirl.create(:klingonian) }
      let(:language_root) { FactoryGirl.create(:language_root_page, language: language) }
      let(:new_lang_root) { Page.language_root_for(new_language.id) }

      before(:each) do
        level_1 = FactoryGirl.create(:public_page, parent_id: language_root.id, visible: true, name: 'Level 1')
        level_2 = FactoryGirl.create(:public_page, parent_id: level_1.id, visible: true, name: 'Level 2')
        level_3 = FactoryGirl.create(:public_page, parent_id: level_2.id, visible: true, name: 'Level 3')
        level_4 = FactoryGirl.create(:public_page, parent_id: level_3.id, visible: true, name: 'Level 4')
        session[:language_code] = new_language.code
        session[:language_id] = new_language.id
        post :copy_language_tree, {languages: {new_lang_id: new_language.id, old_lang_id: language.id}}
      end

      it "should copy all pages" do
        new_lang_root.should_not be_nil
        new_lang_root.descendants.count.should == 4
        new_lang_root.descendants.collect(&:name).should == ["Level 1 (Copy)", "Level 2 (Copy)", "Level 3 (Copy)", "Level 4 (Copy)"]
      end

      it "should not set layoutpage attribute to nil" do
        new_lang_root.layoutpage.should_not be_nil
      end

      it "should not set layoutpage attribute to true" do
        new_lang_root.layoutpage.should_not be_true
      end

    end

    describe '#destroy' do

      let(:clipboard) { session[:clipboard] = Clipboard.new }
      let(:page) { FactoryGirl.create(:public_page) }

      before { clipboard[:pages] = [{id: page.id}] }

      it "should also remove the page from clipboard" do
        post :destroy, {id: page.id, _method: :delete, format: 'js'}
        clipboard[:pages].should be_empty
      end

    end

    describe '#publish' do

      let(:page) { stub_model(Page, published_at: nil, public: false, name: "page", parent_id: 1, urlname: "page", language: stub_model(Language), page_layout: "bla") }
      before do
        @controller.stub!(:load_page).and_return(page)
        @controller.instance_variable_set("@page", page)
      end

      it "should publish the page" do
        page.should_receive(:publish!)
        post :publish, { id: page.id }
      end

    end

    describe '#visit' do
      let(:page) { mock_model(Alchemy::Page, urlname: 'home') }

      before do
        Page.stub!(:find).with("#{page.id}").and_return(page)
        page.stub!(:unlock!).and_return(true)
        @controller.stub!(:multi_language?).and_return(false)
      end

      it "should redirect to the page path" do
        expect(post :visit, id: page.id).to redirect_to(show_page_path(urlname: 'home'))
      end
    end

    describe '#fold' do
      let(:page) { mock_model(Alchemy::Page) }
      before { Page.stub(:find).and_return(page) }

      context "if page is currently not folded" do
        before { page.stub(:folded?).and_return(false) }

        it "should fold the page" do
          page.should_receive(:fold!).with(user.id, true).and_return(true)
          post :fold, id: page.id, format: :js
        end
      end

      context "if page is already folded" do
        before { page.stub(:folded?).and_return(true) }

        it "should unfold the page" do
          page.should_receive(:fold!).with(user.id, false).and_return(true)
          post :fold, id: page.id, format: :js
        end
      end
    end

    describe '#sort' do
      before { Page.stub(:language_root_for).and_return(mock_model(Alchemy::Page)) }

      it "should assign @sorting with true" do
        get :sort, format: :js
        expect(assigns(:sorting)).to eq(true)
      end
    end

    describe '#unlock' do
      let(:page) { mock_model(Alchemy::Page, name: 'Best practices') }

      before do
        Page.stub(:find).with("#{page.id}").and_return(page)
        Page.stub_chain(:from_current_site, :all_locked_by).and_return(nil)
        page.should_receive(:unlock!).and_return(true)
      end

      it "should unlock the page" do
        post :unlock, id: "#{page.id}", format: :js
      end

      context 'requesting for html format' do
        it "should redirect to admin_pages_path" do
          expect(post :unlock, id: page.id).to redirect_to(admin_pages_path)
        end

        context 'if passing :redirect_to through params' do
          it "should redirect to the given path" do
            expect(post :unlock, id: page.id, redirect_to: 'this/path').to redirect_to('this/path')
          end
        end
      end
    end

  end
end
