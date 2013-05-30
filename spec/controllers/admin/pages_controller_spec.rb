require 'ostruct'
require 'spec_helper'

module Alchemy
  describe Admin::PagesController do

    before do
      sign_in(admin_user)
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
        let(:page) { mock_model('Page', name: 'Foobar') }

        before do
          clipboard[:pages] = [{id: page.id, action: 'copy'}]
        end

        it "should load all pages from clipboard" do
          get :new, {page_id: page.id, format: :js}
          assigns(:clipboard_items).should be_kind_of(Array)
        end

      end
    end

    describe '#show' do

      let(:page) { mock_model('Page', language_code: 'nl') }

      before do
        Page.stub!(:find).with("#{page.id}").and_return(page)
        Page.stub!(:language_root_for).and_return(mock_model('Page'))
      end

      it "should assign @preview_mode with true" do
        post :show, id: page.id
        expect(assigns(:preview_mode)).to eq(true)
      end

      it "should set the I18n locale to the pages language code" do
        post :show, id: page.id
        expect(::I18n.locale).to eq(:nl)
      end
    end

    describe "#configure" do
      render_views

      context "with page having nested urlname" do
        let(:page) { mock_model(Page, {name: 'Foobar', slug: 'foobar', urlname: 'root/parent/foobar', redirects_to_external?: false, layoutpage?: false, taggable?: false}) }

        it "should always show the slug" do
          Page.stub!(:find).and_return(page)
          get :configure, {id: page.id, format: :js}
          response.body.should match /value="foobar"/
        end
      end
    end

    describe '#create' do

      let(:parent) { FactoryGirl.create(:public_page) }

      context "with paste_from_clipboard in parameters" do
        render_views

        let(:clipboard) { session[:clipboard] = Clipboard.new }
        let(:page_in_clipboard) { FactoryGirl.create(:public_page) }

        before(:each) do
          clipboard[:pages] = [{id: page_in_clipboard.id, action: 'cut'}]
        end

        it "should create a page from clipboard" do
          post :create, {paste_from_clipboard: page_in_clipboard.id, page: {parent_id: parent.id}, format: :js}
          response.status.should == 200
          response.body.should match /window.location.*admin.*pages/
        end

      end

      context "with redirect_to in the parameters" do

        let(:page_params) do
          {name: "Foobar", page_layout: 'standard', parent_id: parent.id}
        end

        it "should redirect to given url" do
          post :create, page: page_params, redirect_to: admin_users_path
          response.should redirect_to(admin_users_path)
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

      before do
        clipboard[:pages] = [{id: page.id}]
      end

      it "should also remove the page from clipboard" do
        post :destroy, {id: page.id, _method: :delete}
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
      let(:page) { mock_model('Page', urlname: 'home') }

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
      let(:page) { mock_model('Page') }

      before do
        Page.stub!(:find).with(page.id).and_return(page)
      end

      context "if page is currently not folded" do
        before do
          page.stub!(:folded?).and_return(false)
        end

        it "should fold the page" do
          page.should_receive(:fold!).with(controller.current_user.id, true).and_return(true)
          post :fold, id: page.id, format: :js
        end
      end

      context "if page is already folded" do
        before do
          page.stub!(:folded?).and_return(true)
        end

        it "should unfold the page" do
          page.should_receive(:fold!).with(controller.current_user.id, false).and_return(true)
          post :fold, id: page.id, format: :js
        end
      end
    end

    describe '#sort' do
      before do
        Page.stub!(:language_root_for).and_return(mock_model('Page'))
      end

      it "should assign @sorting with true" do
        get :sort, format: :js
        expect(assigns(:sorting)).to eq(true)
      end
    end

    describe '#unlock' do
      let(:page) { mock_model('Page', name: 'Best practices') }

      before do
        page.stub!(:unlock!).and_return(true)
        Page.stub!(:find).with("#{page.id}").and_return(page)
        Page.stub_chain(:from_current_site, :all_locked_by).and_return(nil)
      end

      it "should unlock the page" do
        page.should_receive(:unlock!)
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
