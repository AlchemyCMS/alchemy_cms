require 'ostruct'
require 'spec_helper'

module Alchemy
  describe Admin::PagesController do
    let(:user) { editor_user }
    before { sign_in(user) }

    describe '#index' do
      let(:language)      { build_stubbed(:language) }
      let(:language_root) { build_stubbed(:language_root_page) }

      context 'with existing language root page' do
        before do
          Language.should_receive(:current_root_page).and_return(language_root)
        end

        it "assigns @page_root variable" do
          get :index
          assigns(:page_root).should be(language_root)
        end
      end

      context 'without language root page' do
        before do
          Language.should_receive(:current_root_page).and_return(nil)
          Language.stub(find_by: language)
          Language.stub(all: [language])
          Language.stub(with_root_page: [language])
        end

        it "it assigns current language" do
          get :index
          assigns(:language).should be(language)
        end
      end
    end

    describe "#flush" do
      let(:page_1) { build_stubbed(:page) }
      let(:page_2) { build_stubbed(:page) }

      before do
        Language.stub_chain(:current, :pages, :flushables).and_return([page_1, page_2])
      end

      it "should remove the cache of all pages" do
        page_1.should_receive(:publish!)
        page_2.should_receive(:publish!)
        xhr :post, :flush
      end
    end

    describe '#new' do
      context "pages in clipboard" do
        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:page) { mock_model(Alchemy::Page, name: 'Foobar') }

        before { clipboard[:pages] = [{id: page.id, action: 'copy'}] }

        it "should load all pages from clipboard" do
          xhr :get, :new, {page_id: page.id}
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

      it "should store page as current preview" do
        Page.current_preview = nil
        get :show, id: page.id
        Page.current_preview.should == page
      end

      it "should set the I18n locale to the pages language code" do
        get :show, id: page.id
        expect(::I18n.locale).to eq(:nl)
      end
    end

    describe "#configure" do
      render_views

      context "with page having nested urlname" do
        let(:page) { mock_model(Page, {name: 'Foobar', slug: 'foobar', urlname: 'root/parent/foobar', redirects_to_external?: false, layoutpage?: false, taggable?: false}) }

        it "should always show the slug" do
          Page.stub(:find).and_return(page)
          xhr :get, :configure, {id: page.id}
          response.body.should match /value="foobar"/
        end
      end
    end

    describe '#create' do
      let(:language)    { mock_model('Language', code: 'kl') }
      let(:parent)      { mock_model('Page', language: language) }
      let(:page_params) { {parent_id: parent.id, name: 'new Page'} }

      context "a new page" do
        before do
          Page.any_instance.stub(:set_language_from_parent_or_default)
          Page.any_instance.stub(save: true)
        end

        it "is nested under given parent" do
          controller.stub(:edit_admin_page_path).and_return('bla')
          xhr :post, :create, {page: page_params}
          expect(assigns(:page).parent_id).to eq(parent.id)
        end

        it "redirects to edit page template" do
          page = mock_model('Page')
          controller.should_receive(:edit_admin_page_path).and_return('bla')
          post :create, page: page_params
          response.should redirect_to('bla')
        end

        context "if new page can not be saved" do
          it "renders the create form" do
            Page.any_instance.stub(:save).and_return(false)
            post :create, page: {name: 'page'}
            response.should render_template('new')
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
            render_views

            it "should render the `new` template" do
              Page.any_instance.stub(:save).and_return(false)
              xhr :post, :create, page: {name: 'page'}, redirect_to: admin_pictures_path
              response.body.should match /form.+action=\"\/admin\/pages\"/
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
          Page.stub(:find_by).with(id: "#{parent.id}").and_return(parent)
          Page.stub(:find).with("#{page_in_clipboard.id}").and_return(page_in_clipboard)
        end

        it "should call Page#paste_from_clipboard" do
          Page.should_receive(:paste_from_clipboard).with(
            page_in_clipboard,
            parent,
            'pasted Page'
          ).and_return(
            mock_model('Page', save: true, name: 'pasted Page', redirects_to_external?: false)
          )
          xhr :post, :create, {paste_from_clipboard: page_in_clipboard.id, page: {parent_id: parent.id, name: 'pasted Page'}}
        end
      end
    end

    describe '#copy_language_tree' do
      let(:params)                     { {languages: {new_lang_id: '2', old_lang_id: '1'}} }
      let(:language_root_to_copy_from) { build_stubbed(:language_root_page) }
      let(:copy_of_language_root)      { build_stubbed(:language_root_page) }
      let(:root_page)                  { mock_model('Page') }

      before do
        Page.stub(copy: copy_of_language_root)
        Page.stub(root: root_page)
        Page.stub(language_root_for: language_root_to_copy_from)
        Page.any_instance.stub(:move_to_child_of)
        Page.any_instance.stub(:copy_children_to)
        controller.stub(:store_current_language)
        Language.stub(:current).and_return(mock_model('Language', language_code: 'it', code: 'it'))
      end

      it "should copy the language root page over to the other language" do
        Page.should_receive(:copy).with(language_root_to_copy_from, {language_id: '2', language_code: 'it'})
        post :copy_language_tree, params
      end

      it "should move the newly created language-root-page below the absolute root page" do
        copy_of_language_root.should_receive(:move_to_child_of).with(root_page)
        post :copy_language_tree, params
      end

      it "should copy all childs of the original page over to the new created one" do
        controller.stub(language_root_to_copy_from: language_root_to_copy_from)
        controller.stub(copy_of_language_root: copy_of_language_root)
        language_root_to_copy_from.should_receive(:copy_children_to).with(copy_of_language_root)
        post :copy_language_tree, params
      end

      it "should redirect to admin_pages_path" do
        controller.stub(:copy_of_language_root)
        controller.stub_chain(:language_root_to_copy_from, :copy_children_to)
        post :copy_language_tree, params
        expect(response).to redirect_to(admin_pages_path)
      end
    end

    describe '#destroy' do
      let(:clipboard) { session[:clipboard] = Clipboard.new }
      let(:page) { FactoryGirl.create(:public_page) }

      before { clipboard[:pages] = [{id: page.id}] }

      it "should also remove the page from clipboard" do
        xhr :post, :destroy, {id: page.id, _method: :delete}
        clipboard[:pages].should be_empty
      end
    end

    describe '#publish' do
      let(:page) { stub_model(Page, published_at: nil, public: false, name: "page", parent_id: 1, urlname: "page", language: stub_model(Language), page_layout: "bla") }

      before do
        @controller.stub(:load_page).and_return(page)
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
        Page.stub(:find).with("#{page.id}").and_return(page)
        page.stub(:unlock!).and_return(true)
        @controller.stub(:multi_language?).and_return(false)
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
          xhr :post, :fold, id: page.id
        end
      end

      context "if page is already folded" do
        before { page.stub(:folded?).and_return(true) }

        it "should unfold the page" do
          page.should_receive(:fold!).with(user.id, false).and_return(true)
          xhr :post, :fold, id: page.id
        end
      end
    end

    describe '#sort' do
      before { Page.stub(:language_root_for).and_return(mock_model(Alchemy::Page)) }

      it "should assign @sorting with true" do
        xhr :get, :sort
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
        xhr :post, :unlock, id: "#{page.id}"
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

    describe "#switch_language" do
      let(:language) { build_stubbed(:klingonian)}

      before do
        Language.stub(:find_by).and_return(language)
      end

      it "should store the current language in session" do
        get :switch_language, {language_id: language.id}
        expect(session[:alchemy_language_id]).to eq(language.id)
      end

      it "should redirect to sitemap" do
        expect(get :switch_language, {language_id: language.id}).to redirect_to(admin_pages_path)
      end

      context "coming from layoutpages" do
        before {
          request.stub(:referer).and_return('admin/layoutpages')
        }

        it "should redirect to layoutpages" do
          expect(get :switch_language, {language_id: language.id}).to redirect_to(admin_layoutpages_path)
        end
      end
    end

  end
end
