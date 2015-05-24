require 'ostruct'
require 'spec_helper'

module Alchemy
  describe Admin::PagesController do

    context 'a guest' do
      it 'can not access page tree' do
        alchemy_get :index
        expect(request).to redirect_to(Alchemy.login_path)
      end
    end

    context 'a member' do
      before { authorize_user(build(:alchemy_dummy_user)) }

      it 'can not access page tree' do
        alchemy_get :index
        expect(request).to redirect_to(root_path)
      end
    end

    context 'with logged in editor user' do
      let(:user) { build(:alchemy_dummy_user, :as_editor) }

      before { authorize_user(user) }

      describe '#index' do
        let(:language)      { build_stubbed(:language) }
        let(:language_root) { build_stubbed(:language_root_page) }

        context 'with existing language root page' do
          before do
            expect(Language).to receive(:current_root_page).and_return(language_root)
          end

          it "assigns @page_root variable" do
            alchemy_get :index
            expect(assigns(:page_root)).to be(language_root)
          end
        end

        context 'without language root page' do
          before do
            expect(Language).to receive(:current_root_page).and_return(nil)
            expect(Language).to receive(:find_by).and_return(language)
            expect(Language).to receive(:all).and_return([language])
            expect(Language).to receive(:with_root_page).and_return([language])
          end

          it "it assigns current language" do
            alchemy_get :index
            expect(assigns(:language)).to be(language)
          end
        end
      end

      describe "#flush" do
        let(:language) { mock_model('Language', code: 'en', pages: double(flushables: [page_1, page_2])) }
        let(:page_1)   { build_stubbed(:page) }
        let(:page_2)   { build_stubbed(:page) }

        before do
          expect(Language).to receive(:current).at_least(:once).and_return(language)
        end

        it "should remove the cache of all pages" do
          expect(page_1).to receive(:publish!)
          expect(page_2).to receive(:publish!)
          alchemy_xhr :post, :flush
        end
      end

      describe '#new' do
        context "pages in clipboard" do
          let(:clipboard) { session[:alchemy_clipboard] = {} }
          let(:page) { mock_model(Alchemy::Page, name: 'Foobar') }

          before { clipboard['pages'] = [{'id' => page.id.to_s, 'action' => 'copy'}] }

          it "should load all pages from clipboard" do
            alchemy_xhr :get, :new, {page_id: page.id}
            expect(assigns(:clipboard_items)).to be_kind_of(Array)
          end
        end
      end

      describe '#show' do
        let(:page) { build_stubbed(:page, language_code: 'nl') }

        before do
          expect(Page).to receive(:find).with("#{page.id}").and_return(page)
          allow(Page).to receive(:language_root_for).and_return(mock_model(Alchemy::Page))
        end

        it "should assign @preview_mode with true" do
          alchemy_get :show, id: page.id
          expect(assigns(:preview_mode)).to eq(true)
        end

        it "should store page as current preview" do
          Page.current_preview = nil
          alchemy_get :show, id: page.id
          expect(Page.current_preview).to eq(page)
        end

        it "should set the I18n locale to the pages language code" do
          alchemy_get :show, id: page.id
          expect(::I18n.locale).to eq(:nl)
        end

        it "renders the application layout" do
          alchemy_get :show, id: page.id
          expect(response).to render_template(layout: 'application')
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
          alchemy_xhr :post, :order, set: set_of_pages.to_json
          page_1.reload
          expect(page_1.descendants).to eq([page_2, page_3])
        end

        context 'with url nesting enabled' do
          before do
            expect(Alchemy::Config).to receive(:get).with(:url_nesting).at_least(:once).and_return(true)
          end

          it "updates the pages urlnames" do
            alchemy_xhr :post, :order, set: set_of_pages.to_json
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
              alchemy_xhr :post, :order, set: set_of_pages.to_json
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
              alchemy_xhr :post, :order, set: set_of_pages.to_json
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
              alchemy_xhr :post, :order, set: set_of_pages.to_json
              page_3.reload
              expect(page_3.restricted).to be_truthy
            end
          end

          context 'with page having number as slug' do
            let(:page_item_2) do
              {
                id: page_2.id,
                slug: 42,
                children: [page_item_3]
              }
            end

            it "does not raise error" do
              expect {
                alchemy_xhr :post, :order, set: set_of_pages.to_json
              }.not_to raise_error
            end

            it "still generates the correct urlname on page_3" do
              alchemy_xhr :post, :order, set: set_of_pages.to_json
              [page_1, page_2, page_3].map(&:reload)
              expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
            end
          end

          it "creates legacy urls" do
            alchemy_xhr :post, :order, set: set_of_pages.to_json
            [page_2, page_3].map(&:reload)
            expect(page_2.legacy_urls.size).to eq(1)
            expect(page_3.legacy_urls.size).to eq(1)
          end
        end
      end

      describe "#configure" do
        render_views

        context "with page having nested urlname" do
          let(:page) { create(:page, name: 'Foobar', urlname: 'foobar') }

          it "should always show the slug" do
            alchemy_xhr :get, :configure, {id: page.id}
            expect(response.body).to match /value="foobar"/
          end
        end
      end

      describe '#create' do
        let(:language)    { mock_model('Language', code: 'kl') }
        let(:parent)      { mock_model('Page', language: language) }
        let(:page_params) { {parent_id: parent.id, name: 'new Page'} }

        context "a new page" do
          before do
            allow_any_instance_of(Page).to receive(:set_language_from_parent_or_default)
            allow_any_instance_of(Page).to receive(:save).and_return(true)
          end

          it "is nested under given parent" do
            allow(controller).to receive(:edit_admin_page_path).and_return('bla')
            alchemy_xhr :post, :create, {page: page_params}
            expect(assigns(:page).parent_id).to eq(parent.id)
          end

          it "redirects to edit page template" do
            page = mock_model('Page')
            expect(controller).to receive(:edit_admin_page_path).and_return('bla')
            alchemy_post :create, page: page_params
            expect(response).to redirect_to('bla')
          end

          context "if new page can not be saved" do
            it "renders the create form" do
              allow_any_instance_of(Page).to receive(:save).and_return(false)
              alchemy_post :create, page: {name: 'page'}
              expect(response).to render_template('new')
            end
          end

          context "with redirect_to in params" do
            let(:page_params) do
              {name: "Foobar", page_layout: 'standard', parent_id: parent.id}
            end

            it "should redirect to given url" do
              alchemy_post :create, page: page_params, redirect_to: admin_pictures_path
              expect(response).to redirect_to(admin_pictures_path)
            end

            context "but new page can not be saved" do
              render_views

              it "should render the `new` template" do
                allow_any_instance_of(Page).to receive(:save).and_return(false)
                alchemy_xhr :post, :create, page: {name: 'page'}, redirect_to: admin_pictures_path
                expect(response.body).to match /form.+action=\"\/admin\/pages\"/
              end
            end
          end

          context 'with page redirecting to external' do
            it "redirects to sitemap" do
              expect_any_instance_of(Page).to receive(:redirects_to_external?).and_return(true)
              alchemy_post :create, page: page_params
              expect(response).to redirect_to(admin_pages_path)
            end
          end
        end

        context "with paste_from_clipboard in parameters" do
          let(:page_in_clipboard) { mock_model(Alchemy::Page) }

          before do
            allow(Page).to receive(:find_by).with(id: "#{parent.id}").and_return(parent)
            allow(Page).to receive(:find).with("#{page_in_clipboard.id}").and_return(page_in_clipboard)
          end

          it "should call Page#copy_and_paste" do
            expect(Page).to receive(:copy_and_paste).with(
              page_in_clipboard,
              parent,
              'pasted Page'
            ).and_return(
              mock_model('Page', save: true, name: 'pasted Page', redirects_to_external?: false)
            )
            alchemy_xhr :post, :create, {paste_from_clipboard: page_in_clipboard.id, page: {parent_id: parent.id, name: 'pasted Page'}}
          end
        end
      end

      describe '#copy_language_tree' do
        let(:params)                     { {languages: {new_lang_id: '2', old_lang_id: '1'}} }
        let(:language_root_to_copy_from) { build_stubbed(:language_root_page) }
        let(:copy_of_language_root)      { build_stubbed(:language_root_page) }
        let(:root_page)                  { mock_model('Page') }

        before do
          allow(Page).to receive(:copy).and_return(copy_of_language_root)
          allow(Page).to receive(:root).and_return(root_page)
          allow(Page).to receive(:language_root_for).and_return(language_root_to_copy_from)
          allow_any_instance_of(Page).to receive(:move_to_child_of)
          allow_any_instance_of(Page).to receive(:copy_children_to)
          allow(controller).to receive(:store_current_language)
          allow(Language).to receive(:current).and_return(mock_model('Language', language_code: 'it', code: 'it'))
        end

        it "should copy the language root page over to the other language" do
          expect(Page).to receive(:copy).with(language_root_to_copy_from, {language_id: '2', language_code: 'it'})
          alchemy_post :copy_language_tree, params
        end

        it "should move the newly created language-root-page below the absolute root page" do
          expect(copy_of_language_root).to receive(:move_to_child_of).with(root_page)
          alchemy_post :copy_language_tree, params
        end

        it "should copy all childs of the original page over to the new created one" do
          expect(controller).to receive(:language_root_to_copy_from).and_return(language_root_to_copy_from)
          expect(controller).to receive(:copy_of_language_root).and_return(copy_of_language_root)
          expect(language_root_to_copy_from).to receive(:copy_children_to).with(copy_of_language_root)
          alchemy_post :copy_language_tree, params
        end

        it "should redirect to admin_pages_path" do
          allow(controller).to receive(:copy_of_language_root)
          allow(controller).to receive(:language_root_to_copy_from).and_return(double(copy_children_to: nil))
          alchemy_post :copy_language_tree, params
          expect(response).to redirect_to(admin_pages_path)
        end
      end

      describe '#edit' do
        let!(:page)       { create(:page) }
        let!(:other_user) { create(:alchemy_dummy_user, :as_author) }

        context 'if page is locked by another user' do
          before { page.lock_to!(other_user) }

          context 'that is signed in' do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(true)
            end

            it 'redirects to sitemap' do
              alchemy_get :edit, id: page.id
              expect(response).to redirect_to(admin_pages_path)
            end
          end

          context 'that is not signed in' do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(false)
            end

            it 'renders the edit view' do
              alchemy_get :edit, id: page.id
              expect(response).to render_template(:edit)
            end
          end
        end

        context 'if page is locked by myself' do
          before do
            expect_any_instance_of(Page).to receive(:locker).and_return(user)
            expect(user).to receive(:logged_in?).and_return(true)
          end

          it 'renders the edit view' do
            alchemy_get :edit, id: page.id
            expect(response).to render_template(:edit)
          end
        end

        context 'if page is not locked' do
          before do
            expect_any_instance_of(Page).to receive(:locker).and_return(nil)
          end

          it 'renders the edit view' do
            alchemy_get :edit, id: page.id
            expect(response).to render_template(:edit)
          end

          it "lockes the page to myself" do
            expect_any_instance_of(Page).to receive(:lock_to!)
            alchemy_get :edit, id: page.id
          end
        end
      end

      describe '#destroy' do
        let(:clipboard) { session[:alchemy_clipboard] = {} }
        let(:page) { FactoryGirl.create(:public_page) }

        before { clipboard['pages'] = [{'id' => page.id.to_s}] }

        it "should also remove the page from clipboard" do
          alchemy_xhr :post, :destroy, {id: page.id, _method: :delete}
          expect(clipboard['pages']).to be_empty
        end
      end

      describe '#publish' do
        let(:page) { stub_model(Page, published_at: nil, public: false, name: "page", parent_id: 1, urlname: "page", language: stub_model(Language), page_layout: "bla") }

        before do
          allow(@controller).to receive(:load_page).and_return(page)
          @controller.instance_variable_set("@page", page)
        end

        it "should publish the page" do
          expect(page).to receive(:publish!)
          alchemy_post :publish, { id: page.id }
        end
      end

      describe '#visit' do
        let(:page) { mock_model(Alchemy::Page, urlname: 'home') }

        before do
          allow(Page).to receive(:find).with("#{page.id}").and_return(page)
          allow(page).to receive(:unlock!).and_return(true)
          allow(@controller).to receive(:multi_language?).and_return(false)
        end

        it "should redirect to the page path" do
          expect(alchemy_post :visit, id: page.id).to redirect_to(show_page_path(urlname: 'home'))
        end
      end

      describe '#fold' do
        let(:page) { mock_model(Alchemy::Page) }
        before { allow(Page).to receive(:find).and_return(page) }

        context "if page is currently not folded" do
          before { allow(page).to receive(:folded?).and_return(false) }

          it "should fold the page" do
            expect(page).to receive(:fold!).with(user.id, true).and_return(true)
            alchemy_xhr :post, :fold, id: page.id
          end
        end

        context "if page is already folded" do
          before { allow(page).to receive(:folded?).and_return(true) }

          it "should unfold the page" do
            expect(page).to receive(:fold!).with(user.id, false).and_return(true)
            alchemy_xhr :post, :fold, id: page.id
          end
        end
      end

      describe '#sort' do
        before { allow(Page).to receive(:language_root_for).and_return(mock_model(Alchemy::Page)) }

        it "should assign @sorting with true" do
          alchemy_xhr :get, :sort
          expect(assigns(:sorting)).to eq(true)
        end
      end

      describe '#unlock' do
        let(:page) { mock_model(Alchemy::Page, name: 'Best practices') }

        before do
          allow(Page).to receive(:find).with("#{page.id}").and_return(page)
          allow(Page).to receive(:from_current_site).and_return(double(all_locked_by: nil))
          expect(page).to receive(:unlock!).and_return(true)
        end

        it "should unlock the page" do
          alchemy_xhr :post, :unlock, id: "#{page.id}"
        end

        context 'requesting for html format' do
          it "should redirect to admin_pages_path" do
            expect(alchemy_post :unlock, id: page.id).to redirect_to(admin_pages_path)
          end

          context 'if passing :redirect_to through params' do
            it "should redirect to the given path" do
              expect(alchemy_post :unlock, id: page.id, redirect_to: 'this/path').to redirect_to('this/path')
            end
          end
        end
      end

      describe "#switch_language" do
        let(:language) { build_stubbed(:klingonian)}

        before do
          allow(Language).to receive(:find_by).and_return(language)
        end

        it "should store the current language in session" do
          alchemy_get :switch_language, {language_id: language.id}
          expect(session[:alchemy_language_id]).to eq(language.id)
        end

        it "should redirect to sitemap" do
          expect(alchemy_get :switch_language, {language_id: language.id}).to redirect_to(admin_pages_path)
        end

        context "coming from layoutpages" do
          before {
            allow(request).to receive(:referer).and_return('admin/layoutpages')
          }

          it "should redirect to layoutpages" do
            expect(alchemy_get :switch_language, {language_id: language.id}).to redirect_to(admin_layoutpages_path)
          end
        end
      end
    end
  end
end
