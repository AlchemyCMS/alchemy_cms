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
        context 'with locked pages' do
          let(:locked_page) { create(:alchemy_page, locked: true, locked_by: user.id) }

          it "it assigns locked pages" do
            alchemy_get :index
            expect(assigns(:locked_pages)).to include(locked_page)
          end
        end
      end

      describe "#flush" do
        let(:content_page_1) { create(:alchemy_page, :public, name: "content page 1", published_at: Time.current - 5.days) }
        let(:content_page_2) { create(:alchemy_page, :public, name: "content page 2", published_at: Time.current - 8.days) }
        let(:layout_page_1)  { create(:alchemy_page, layoutpage: true, name: "layout_page 1", published_at: Time.current - 5.days) }
        let(:layout_page_2)  { create(:alchemy_page, layoutpage: true, name: "layout_page 2", published_at: Time.current - 8.days) }
        let(:content_pages)  { [content_page_1, content_page_2] }
        let(:layout_pages)   { [layout_page_1, layout_page_2] }

        before do
          content_pages
          layout_pages
        end

        it "should update the published_at field of content pages" do
          travel_to(Time.current) do
            alchemy_xhr :post, :flush
            content_pages.map(&:reload) # Reloading because published_at was directly updated in the database.
            content_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
        end

        it "should update the published_at field of layout pages" do
          travel_to(Time.current) do
            alchemy_xhr :post, :flush
            layout_pages.map(&:reload) # Reloading because published_at was directly updated in the database.
            layout_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
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
        let(:page) { build_stubbed(:alchemy_page, language_code: 'nl') }

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

      describe "#configure" do
        render_views

        context "with page having nested urlname" do
          let(:page) { create(:alchemy_page, name: 'Foobar', urlname: 'foobar') }

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

      # TODO: Refactor copy_language_tree
      # describe '#copy_language_tree' do
      #   let(:params)                     { {languages: {new_lang_id: '2', old_lang_id: '1'}} }
      #   let(:language_root_to_copy_from) { build_stubbed(: alchemy_page, :language_root) }
      #   let(:copy_of_language_root)      { build_stubbed(: alchemy_page, :language_root) }
      #   let(:root_page)                  { mock_model('Page') }
      #
      #   before do
      #     allow(Page).to receive(:copy).and_return(copy_of_language_root)
      #     allow(Page).to receive(:root).and_return(root_page)
      #     allow(Page).to receive(:language_root_for).and_return(language_root_to_copy_from)
      #     allow_any_instance_of(Page).to receive(:move_to_child_of)
      #     allow_any_instance_of(Page).to receive(:copy_children_to)
      #     allow(controller).to receive(:store_current_language)
      #     allow(Language).to receive(:current).and_return(mock_model('Language', language_code: 'it', code: 'it'))
      #   end
      #
      #   it "should copy the language root page over to the other language" do
      #     expect(Page).to receive(:copy).with(language_root_to_copy_from, {language_id: '2', language_code: 'it'})
      #     alchemy_post :copy_language_tree, params
      #   end
      #
      #   it "should move the newly created language-root-page below the absolute root page" do
      #     expect(copy_of_language_root).to receive(:move_to_child_of).with(root_page)
      #     alchemy_post :copy_language_tree, params
      #   end
      #
      #   it "should copy all childs of the original page over to the new created one" do
      #     expect(controller).to receive(:language_root_to_copy_from).and_return(language_root_to_copy_from)
      #     expect(controller).to receive(:copy_of_language_root).and_return(copy_of_language_root)
      #     expect(language_root_to_copy_from).to receive(:copy_children_to).with(copy_of_language_root)
      #     alchemy_post :copy_language_tree, params
      #   end
      #
      #   it "should redirect to admin_pages_path" do
      #     allow(controller).to receive(:copy_of_language_root)
      #     allow(controller).to receive(:language_root_to_copy_from).and_return(double(copy_children_to: nil))
      #     alchemy_post :copy_language_tree, params
      #     expect(response).to redirect_to(admin_pages_path)
      #   end
      # end

      describe '#edit' do
        let!(:page)       { create(:alchemy_page) }
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
          let(:locked_page) { create(:page, locked: true, locked_by: user.id) }

          before do
            expect(user).to receive(:logged_in?).and_return(true)
          end

          it 'renders the edit view' do
            alchemy_get :edit, id: page.id
            expect(response).to render_template(:edit)
          end

          it "it assigns locked pages" do
            get :edit, id: page.id
            expect(assigns(:locked_pages)).to include(locked_page)
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
        let(:page)      { create(: alchemy_page, :public) }

        before do
          clipboard['pages'] = [{'id' => page.id.to_s}]
        end

        it "should also remove the page from clipboard" do
          alchemy_xhr :post, :destroy, {id: page.id, _method: :delete}
          expect(clipboard['pages']).to be_empty
        end
      end

      describe '#info' do
        let(:page) { create(:page) }

        it "shows information about the page" do
          get :info, id: page.id
          expect(assigns('page')).to eq(page)
        end
      end

      describe '#link' do
        let(:attachment) do
          mock_model(Attachment, name: 'attachment', urlname: 'attachment')
        end

        it 'assign content_id' do
          get :link, content_id: 1
          expect(assigns('content_id')).to eq('1')
        end

        it "assigns attachments for select" do
          allow(Attachment).to receive(:all).and_return([attachment])
          get :link
          expect(assigns('attachments')).to eq([
            [attachment.name, "/attachment/#{attachment.id}/download/#{attachment.name}"]
          ])
        end

        context 'in multi_language mode' do
          before { controller.stub(multi_language?: true) }

          it "assigns url_prefix" do
            get :link
            expect(assigns('url_prefix')).to eq('en/')
          end
        end
      end

      describe '#publish' do
        let(:page) { stub_model(Page, published_at: nil, public: false, name: "page", parent_id: 1, urlname: "page", language: stub_model(Language), page_layout: "bla") }

        before do
          allow(controller).to receive(:load_page).and_return(page)
          controller.instance_variable_set("@page", page)
        end

        it "should publish the page" do
          expect(page).to receive(:publish!)
          alchemy_post :publish, { id: page.id }
        end
      end

      describe '#upate' do
        let(:page) { create(:page) }

        before do
          allow(Page).to receive(:find).and_return(page)
        end

        it 'stores old page layout' do
          allow(request).to receive(:referer).and_return([])
          post :update, id: page.id, page: page.attributes
          expect(assigns('old_page_layout')).to eq(page.page_layout)
        end

        context 'successful save' do
          context 'if the referer was edit' do
            before do
              allow(request).to receive(:referer).and_return(%w(edit))
            end

            it 'assign while_page_edit to true' do
              post :update, id: page.id, page: page.attributes
              expect(assigns('while_page_edit')).to be_true
            end
          end

          context 'if the referer is not edit' do
            before do
              allow(request).to receive(:referer).and_return(%w(configure))
            end

            it 'assign while_page_edit to false' do
              post :update, id: page.id, page: page.attributes
              expect(assigns('while_page_edit')).to be_false
            end
          end
        end

        context 'not saved' do
          before do
            allow(page).to receive(:update).and_return(false)
          end

          it 'calls configure' do
            allow(request).to receive(:referer).and_return([])
            expect(controller).to receive(:configure)
            xhr :post, :update, id: page.id, page: {urlname: ''}
          end
        end
      end

      describe '#visit' do
        let(:page) { mock_model(Alchemy::Page, urlname: 'home') }

        before do
          allow(Page).to receive(:find).with("#{page.id}").and_return(page)
          allow(controller).to receive(:multi_language?).and_return(false)
          expect(page).to receive(:unlock!).and_return(true)
        end

        it "should redirect to the page path" do
          expect(post :visit, id: page.id).to redirect_to(show_page_path(urlname: 'home'))
        end
      end

      describe '#unlock' do
        let(:page) { mock_model(Alchemy::Page, name: 'Best practices') }

        before do
          allow(Page).to receive(:find).with("#{page.id}").and_return(page)
          allow(Page).to receive(:from_current_site).and_return(double(locked_by: nil))
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
    end
  end
end
