# frozen_string_literal: true

require "ostruct"
require "rails_helper"

module Alchemy
  describe Admin::PagesController do
    let(:site) { create(:alchemy_site, host: "*") }

    context "a guest" do
      it "can not access page tree" do
        get admin_pages_path
        expect(request).to redirect_to(Alchemy.login_path)
      end

      it "can not access page preview of a public page" do
        page = create(:alchemy_page, :public)
        get admin_page_path(page)
        expect(request).to redirect_to(Alchemy.login_path)
      end
    end

    context "a member" do
      before { authorize_user(build(:alchemy_dummy_user)) }

      it "can not access page tree" do
        get admin_pages_path
        expect(request).to redirect_to(root_path)
      end

      it "can not access page preview of a public page" do
        page = create(:alchemy_page, :public)
        get admin_page_path(page)
        expect(request).to redirect_to("/")
      end
    end

    context "with logged in editor user" do
      let(:user) { build(:alchemy_dummy_user, :as_editor) }

      before { authorize_user(user) }

      describe "#index" do
        context "with existing language root page" do
          let!(:language_root) { create(:alchemy_page, :language_root) }

          it "assigns @pages variable" do
            get admin_pages_path
            expect(assigns(:pages)).to include(language_root)
          end
        end

        context "without current language present" do
          it "it redirects to the languages admin" do
            get admin_pages_path
            expect(response).to redirect_to(alchemy.admin_languages_path)
          end
        end

        context "with current language present" do
          let!(:language) { create(:alchemy_language, site: site) }
          let!(:language_root) { create(:alchemy_page, :language_root, language: language) }

          it "it assigns current language" do
            get admin_pages_path
            expect(assigns(:current_language)).to eq(language)
          end

          context "with multiple sites" do
            let!(:site_1_language_2) do
              create(:alchemy_language, code: "fr")
            end

            let!(:site_2) do
              create(:alchemy_site, host: "another-one.com")
            end

            let(:site_2_language) do
              create(:alchemy_language, site: site_2)
            end

            before do
              create(:alchemy_page, :language_root, language: site_2_language)
              create(:alchemy_page, :language_root, language: site_1_language_2)
            end

            it "loads languages with pages from current site only" do
              get admin_pages_path
              expect(assigns(:languages_with_page_tree)).to include(site_1_language_2)
              expect(assigns(:languages_with_page_tree)).to_not include(site_2_language)
            end
          end
        end
      end

      describe "#flush" do
        let(:content_page_1) do
          time = Time.current - 5.days
          create :alchemy_page,
            public_on: time,
            name: "content page 1",
            published_at: time
        end

        let(:content_page_2) do
          time = Time.current - 8.days
          create :alchemy_page,
            public_on: time,
            name: "content page 2",
            published_at: time
        end

        let(:layout_page_1) do
          create :alchemy_page, :layoutpage,
            name: "layout_page 1",
            published_at: Time.current - 5.days
        end

        let(:layout_page_2) do
          create :alchemy_page, :layoutpage,
            name: "layout_page 2",
            published_at: Time.current - 8.days
        end

        let(:content_pages) { [content_page_1, content_page_2] }
        let(:layout_pages) { [layout_page_1, layout_page_2] }

        it "should update the published_at field of content pages" do
          content_pages

          travel_to(Time.current) do
            post flush_admin_pages_path, xhr: true
            # Reloading because published_at was directly updated in the database.
            content_pages.map(&:reload)
            content_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
        end

        it "should update the published_at field of layout pages" do
          layout_pages

          travel_to(Time.current) do
            post flush_admin_pages_path, xhr: true
            # Reloading because published_at was directly updated in the database.
            layout_pages.map(&:reload)
            layout_pages.each do |page|
              expect(page.published_at).to eq(Time.current)
            end
          end
        end
      end

      describe "#new" do
        context "if no language is present" do
          it "redirects to the language admin" do
            get new_admin_page_path
            expect(response).to redirect_to(admin_languages_path)
          end
        end

        context "with current language present" do
          let!(:language) { create(:alchemy_language) }

          context "pages in clipboard" do
            let(:page) { mock_model(Alchemy::Page, name: "Foobar") }

            before do
              allow_any_instance_of(described_class).to receive(:get_clipboard).with("pages") do
                [{"id" => page.id.to_s, "action" => "copy"}]
              end
            end

            it "should load all pages from clipboard" do
              get new_admin_page_path(page_id: page.id), xhr: true
              expect(assigns(:clipboard_items)).to be_kind_of(Array)
            end
          end
        end
      end

      describe "#show" do
        let(:language) { create(:alchemy_language, locale: "nl") }
        let!(:page) { create(:alchemy_page, language: language) }

        it "can be accessed" do
          get admin_page_path(page)
          expect(response).to be_successful
        end

        it "should assign @preview_mode with true" do
          get admin_page_path(page)
          expect(assigns(:preview_mode)).to eq(true)
        end

        it "should store page as current preview" do
          expect(Current).to receive(:preview_page=).with(page)
          get admin_page_path(page)
        end

        it "should set the I18n locale to the pages language code" do
          get admin_page_path(page)
          expect(::I18n.locale).to eq(:nl)
        end

        it "renders the application layout" do
          get admin_page_path(page)
          expect(response).to render_template(layout: "application")
        end

        context "when layout is set to custom" do
          before do
            stub_alchemy_config(admin_page_preview_layout: "custom")
          end

          it "it renders custom layout instead" do
            get admin_page_path(page)
            expect(response).to render_template(layout: "custom")
          end
        end
      end

      describe "#configure" do
        context "with page having nested urlname" do
          let(:page) { create(:alchemy_page, name: "Foobar", urlname: "foobar") }

          it "should always show the slug" do
            get configure_admin_page_path(page), xhr: true
            expect(response.body).to match(/value="foobar"/)
          end
        end
      end

      describe "#update" do
        let(:page) { create(:alchemy_page) }

        before do
          allow_any_instance_of(ActionDispatch::Request).to receive(:referer) do
            "/admin/pages/edit/#{page.id}"
          end
        end

        context "with valid params" do
          let(:page_params) do
            {
              name: "New Name"
            }
          end

          context "in list view" do
            subject! do
              patch admin_page_path(page, page: page_params, view: "list", format: :turbo_stream)
            end

            it "sets a flash notice" do
              expect(flash[:notice]).to eq("New Name saved")
            end
          end
        end
      end

      describe "#create" do
        subject { post admin_pages_path(page: page_params) }

        let(:parent) { create(:alchemy_page) }

        let(:page_params) do
          {
            parent_id: parent.id,
            name: "new Page",
            page_layout: "standard",
            language_id: parent.language_id
          }
        end

        context "a new page" do
          it "is nested under given parent" do
            subject
            expect(Alchemy::Page.last.parent_id).to eq(parent.id)
          end

          it "redirects to edit page template" do
            expect(subject).to redirect_to(edit_admin_page_path(Alchemy::Page.last))
          end

          context "if new page can not be saved" do
            let(:page_params) do
              {
                parent_id: parent.id,
                name: "new Page"
              }
            end

            it "renders the create form" do
              expect(subject).to render_template(:new)
            end
          end

          context "with redirect_to in params" do
            subject do
              post admin_pages_path(page: page_params, redirect_to: admin_pictures_path)
            end

            it "should redirect to given url" do
              expect(subject).to redirect_to(admin_pictures_path)
            end

            context "when a new page cannot be created" do
              let(:page_params) do
                {
                  parent_id: parent.id,
                  name: "new Page"
                }
              end

              it "should render the `new` template" do
                expect(subject).to render_template(:new)
              end
            end
          end

          context "if page is scoped" do
            context "user role does not match" do
              before do
                allow_any_instance_of(Page).to receive(:editable_by?).with(user).and_return(false)
              end

              it "redirects to admin pages path" do
                post admin_pages_path(page: page_params)
                expect(response).to redirect_to(admin_pages_path)
              end
            end
          end
        end

        context "with paste_from_clipboard in parameters" do
          let(:page_in_clipboard) { create(:alchemy_page) }

          it "should call Page#copy_and_paste" do
            expect(Page).to receive(:copy_and_paste).with(
              page_in_clipboard,
              parent,
              page_params[:name]
            )
            post admin_pages_path(
              page: page_params,
              paste_from_clipboard: page_in_clipboard.id
            ), xhr: true
          end
        end
      end

      describe "#copy_language_tree" do
        let(:params) { {languages: {new_lang_id: "2", old_lang_id: "1"}} }
        let(:language_root_to_copy_from) { build_stubbed(:alchemy_page, :language_root) }
        let(:copy_of_language_root) { build_stubbed(:alchemy_page, :language_root) }
        let(:root_page) { mock_model("Page") }

        before do
          allow(Page).to receive(:copy).and_return(copy_of_language_root)
          allow(Page).to receive(:language_root_for).and_return(language_root_to_copy_from)
          allow_any_instance_of(Page).to receive(:move_to_child_of)
          allow_any_instance_of(Page).to receive(:copy_children_to)
          allow(Current).to receive(:language).and_return(mock_model("Language", locale: "de", code: "de"))
        end

        it "should copy the language root page over to the other language" do
          expect(Page).to receive(:copy).with(language_root_to_copy_from, {language_id: "2", language_code: "de"})
          post copy_language_tree_admin_pages_path(params)
        end

        it "should copy all childs of the original page over to the new created one" do
          expect_any_instance_of(described_class)
            .to receive(:language_root_to_copy_from) { language_root_to_copy_from }
          expect_any_instance_of(described_class)
            .to receive(:copy_of_language_root) { copy_of_language_root }
          expect(language_root_to_copy_from).to receive(:copy_children_to).with(copy_of_language_root)
          post copy_language_tree_admin_pages_path(params)
        end

        it "should redirect to admin_pages_path" do
          allow_any_instance_of(described_class).to receive(:copy_of_language_root)
          allow_any_instance_of(described_class).to receive(:language_root_to_copy_from).and_return(double(copy_children_to: nil))
          post copy_language_tree_admin_pages_path(params)
          expect(response).to redirect_to(admin_pages_path)
        end
      end

      describe "#edit" do
        let!(:page) { create(:alchemy_page) }
        let!(:other_user) { create(:alchemy_dummy_user, :as_author) }

        context "if page is locked by another user" do
          before { page.lock_to!(other_user) }

          context "that is signed in" do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(true)
            end

            it "redirects to sitemap" do
              get edit_admin_page_path(page)
              expect(response).to redirect_to(admin_pages_path)
            end
          end

          context "that is not signed in" do
            before do
              expect_any_instance_of(DummyUser).to receive(:logged_in?).and_return(false)
            end

            it "renders the edit view" do
              get edit_admin_page_path(page)
              expect(response).to render_template(:edit)
            end
          end
        end

        context "if page is locked by myself" do
          before do
            expect_any_instance_of(Page).to receive(:locker).at_least(:once) { user }
            expect(user).to receive(:logged_in?).and_return(true)
          end

          it "renders the edit view" do
            get edit_admin_page_path(page)
            expect(response).to render_template(:edit)
          end

          it "does not lock the page again" do
            expect_any_instance_of(Alchemy::Page).to_not receive(:lock_to!)
            get edit_admin_page_path(page)
          end
        end

        context "if page is not locked" do
          before do
            expect_any_instance_of(Page).to receive(:locker).at_least(:once) { nil }
          end

          it "renders the edit view" do
            get edit_admin_page_path(page)
            expect(response).to render_template(:edit)
          end

          it "lockes the page to myself" do
            expect_any_instance_of(Page).to receive(:lock_to!)
            get edit_admin_page_path(page)
          end
        end

        context "if page is scoped" do
          context "to a single role" do
            context "user role matches" do
              before do
                expect_any_instance_of(Page).to receive(:editable_by?).at_least(:once) { true }
              end

              it "renders the edit view" do
                get edit_admin_page_path(page)
                expect(response).to render_template(:edit)
              end
            end

            context "user role does not match" do
              before do
                expect_any_instance_of(Page).to receive(:editable_by?).at_least(:once) { false }
              end

              it "redirects to admin dashboard" do
                get edit_admin_page_path(page)
                expect(response).to redirect_to(admin_dashboard_path)
              end
            end
          end
        end
      end

      describe "#destroy" do
        let(:clipboard) { [{"id" => page.id.to_s}] }
        let(:page) { create(:alchemy_page, :public) }

        before do
          allow_any_instance_of(described_class).to receive(:get_clipboard).with("pages") do
            clipboard
          end
        end

        it "should also remove the page from clipboard" do
          delete admin_page_path(page), xhr: true
          expect(clipboard).to be_empty
        end
      end

      describe "#publish" do
        let(:page) { create(:alchemy_page, published_at: 3.days.ago) }

        it "published page in the background" do
          expect {
            post publish_admin_page_path(page)
          }.to have_enqueued_job(Alchemy::PublishPageJob)
        end
      end

      describe "#fold" do
        let(:page) { create(:alchemy_page) }
        let(:user) { create(:alchemy_dummy_user, :as_editor) }

        before do
          allow_any_instance_of(described_class).to receive(:current_alchemy_user) { user }
        end

        subject { patch fold_admin_page_path(page), xhr: true }

        context "if page is currently not folded" do
          it "should fold the page" do
            expect { subject }.to change { page.folded?(user.id) }.from(false).to(true)
          end
        end

        context "if page is already folded" do
          before do
            page.fold!(user.id, true)
          end

          it "should unfold the page" do
            expect { subject }.to change { page.folded?(user.id) }.from(true).to(false)
          end
        end
      end

      describe "#unlock" do
        let(:page) { create(:alchemy_page) }
        let(:user) { create(:alchemy_dummy_user, :as_editor) }

        subject { post unlock_admin_page_path(page), xhr: true }

        before do
          page.lock_to!(user)
          allow_any_instance_of(described_class).to receive(:current_alchemy_user) { user }
        end

        it "should unlock the page" do
          expect { subject }.to change { page.reload.locked? }.from(true).to(false)
        end

        context "requesting for html format" do
          subject { post unlock_admin_page_path(page) }

          it "should redirect to admin_pages_path" do
            is_expected.to redirect_to(admin_pages_path)
          end

          context "if passing :redirect_to through params" do
            context "that is admin layout pages path" do
              subject { post unlock_admin_page_path(page, redirect_to: "/admin/layout_pages") }

              it "should redirect to the given path" do
                is_expected.to redirect_to("/admin/layout_pages")
              end
            end

            context "that is admin pages path" do
              subject { post unlock_admin_page_path(page, redirect_to: "/admin/pages") }

              it "should redirect to the given path" do
                is_expected.to redirect_to("/admin/pages")
              end
            end

            context "that is another path" do
              subject { post unlock_admin_page_path(page, redirect_to: "/this/path") }

              it "should redirect to admin_pages_path" do
                is_expected.to redirect_to(admin_pages_path)
              end
            end
          end
        end
      end
    end
  end
end
