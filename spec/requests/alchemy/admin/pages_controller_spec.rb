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
    end

    context "a member" do
      before { authorize_user(build(:alchemy_dummy_user)) }

      it "can not access page tree" do
        get admin_pages_path
        expect(request).to redirect_to(root_path)
      end
    end

    context "with logged in editor user" do
      let(:user) { build(:alchemy_dummy_user, :as_editor) }

      before { authorize_user(user) }

      describe "#index" do
        context "with existing language root page" do
          let!(:language_root) { create(:alchemy_page, :language_root) }

          it "assigns @page_root variable" do
            get admin_pages_path
            expect(assigns(:page_root)).to eq(language_root)
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

          context "without language root page" do
            before do
              expect_any_instance_of(Language).to receive(:root_page).and_return(nil)
            end

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
      end

      describe "#tree" do
        let(:user) { create(:alchemy_dummy_user, :as_editor) }
        let(:page_1) { create(:alchemy_page, name: "one") }
        let(:page_2) { create(:alchemy_page, name: "two", parent_id: page_1.id) }
        let(:page_3) { create(:alchemy_page, name: "three", parent_id: page_2.id) }
        let!(:pages) { [page_1, page_2, page_3] }

        subject :get_tree do
          get tree_admin_pages_path(id: page_1.id, full: "true")
        end

        it "returns a tree as JSON" do
          get_tree

          expect(response.status).to eq(200)
          expect(response.media_type).to eq("application/json")

          result = JSON.parse(response.body)

          expect(result).to have_key("pages")
          expect(result["pages"].count).to eq(1)

          page = result["pages"].first

          expect(page).to have_key("id")
          expect(page["id"]).to eq(page_1.id)
          expect(page).to have_key("name")
          expect(page["name"]).to eq(page_1.name)
          expect(page).to have_key("children")
          expect(page["children"].count).to eq(1)
          expect(page).to have_key("url_path")
          expect(page["url_path"]).to eq(page_1.url_path)

          page = page["children"].first

          expect(page).to have_key("id")
          expect(page["id"]).to eq(page_2.id)
          expect(page).to have_key("name")
          expect(page["name"]).to eq(page_2.name)
          expect(page).to have_key("children")
          expect(page["children"].count).to eq(1)
          expect(page).to have_key("url_path")
          expect(page["url_path"]).to eq(page_2.url_path)

          page = page["children"].first

          expect(page).to have_key("id")
          expect(page["id"]).to eq(page_3.id)
          expect(page).to have_key("name")
          expect(page["name"]).to eq(page_3.name)
          expect(page).to have_key("children")
          expect(page["children"].count).to eq(0)
          expect(page).to have_key("url_path")
          expect(page["url_path"]).to eq(page_3.url_path)
        end

        context "when branch is folded" do
          before do
            page_2.fold!(user.id, true)
          end

          it "does not return a branch that is folded" do
            get tree_admin_pages_path(id: page_1.id, full: "false")

            expect(response.status).to eq(200)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)
            page = result["pages"].first["children"].first

            expect(page["children"].count).to eq(0)
          end
        end

        context "when page is locked" do
          before do
            page_1.lock_to!(user)
          end

          it "includes locked_notice if page is locked" do
            get_tree

            expect(response.status).to eq(200)
            expect(response.media_type).to eq("application/json")

            result = JSON.parse(response.body)

            expect(result).to have_key("pages")
            expect(result["pages"].count).to eq(1)

            page = result["pages"].first
            expect(page).to have_key("locked_notice")
            expect(page["locked_notice"]).to match(/#{user.name}/)
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
                [{ "id" => page.id.to_s, "action" => "copy" }]
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

        it "should assign @preview_mode with true" do
          get admin_page_path(page)
          expect(assigns(:preview_mode)).to eq(true)
        end

        it "should store page as current preview" do
          expect(Page).to receive(:current_preview=).with(page)
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
            allow(Alchemy::Config).to receive(:get) do |arg|
              arg == :admin_page_preview_layout ? "custom" : Alchemy::Config.parameter(arg)
            end
          end

          it "it renders custom layout instead" do
            get admin_page_path(page)
            expect(response).to render_template(layout: "custom")
          end
        end
      end

      describe "#order" do
        let(:page_1) { create(:alchemy_page) }
        let(:page_2) { create(:alchemy_page) }
        let(:page_3) { create(:alchemy_page) }
        let(:page_item_1) { { id: page_1.id, slug: page_1.slug, restricted: false, children: [page_item_2] } }
        let(:page_item_2) { { id: page_2.id, slug: page_2.slug, restricted: false, children: [page_item_3] } }
        let(:page_item_3) { { id: page_3.id, slug: page_3.slug, restricted: false } }
        let(:set_of_pages) { [page_item_1] }

        it "stores the new order" do
          post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
          page_1.reload
          expect(page_1.descendants).to eq([page_2, page_3])
        end

        it "updates the pages urlnames" do
          post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
          [page_1, page_2, page_3].map(&:reload)
          expect(page_1.urlname).to eq(page_1.slug.to_s)
          expect(page_2.urlname).to eq("#{page_1.slug}/#{page_2.slug}")
          expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
        end

        context "with restricted page in tree" do
          let(:page_2) { create(:alchemy_page, restricted: true) }
          let(:page_item_2) do
            {
              id: page_2.id,
              slug: page_2.slug,
              children: [page_item_3],
              restricted: true,
            }
          end

          it "updates restricted status of descendants" do
            post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
            page_3.reload
            expect(page_3.restricted).to be_truthy
          end
        end

        context "with page having number as slug" do
          let(:page_item_2) do
            {
              id: page_2.id,
              slug: 42,
              children: [page_item_3],
            }
          end

          it "does not raise error" do
            expect {
              post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
            }.not_to raise_error
          end

          it "still generates the correct urlname on page_3" do
            post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
            [page_1, page_2, page_3].map(&:reload)
            expect(page_3.urlname).to eq("#{page_1.slug}/#{page_2.slug}/#{page_3.slug}")
          end
        end

        it "creates legacy urls" do
          post order_admin_pages_path(set: set_of_pages.to_json), xhr: true
          [page_2, page_3].map(&:reload)
          expect(page_2.legacy_urls.size).to eq(1)
          expect(page_3.legacy_urls.size).to eq(1)
        end
      end

      describe "#configure" do
        context "with page having nested urlname" do
          let(:page) { create(:alchemy_page, name: "Foobar", urlname: "foobar") }

          it "should always show the slug" do
            get configure_admin_page_path(page), xhr: true
            expect(response.body).to match /value="foobar"/
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
            language_id: parent.language_id,
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
                name: "new Page",
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
                  name: "new Page",
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
              page_params[:name],
            )
            post admin_pages_path(
              page: page_params,
              paste_from_clipboard: page_in_clipboard.id,
            ), xhr: true
          end
        end
      end

      describe "#copy_language_tree" do
        let(:params) { { languages: { new_lang_id: "2", old_lang_id: "1" } } }
        let(:language_root_to_copy_from) { build_stubbed(:alchemy_page, :language_root) }
        let(:copy_of_language_root) { build_stubbed(:alchemy_page, :language_root) }
        let(:root_page) { mock_model("Page") }

        before do
          allow(Page).to receive(:copy).and_return(copy_of_language_root)
          allow(Page).to receive(:language_root_for).and_return(language_root_to_copy_from)
          allow_any_instance_of(Page).to receive(:move_to_child_of)
          allow_any_instance_of(Page).to receive(:copy_children_to)
          allow(Language).to receive(:current).and_return(mock_model("Language", locale: "de", code: "de"))
        end

        it "should copy the language root page over to the other language" do
          expect(Page).to receive(:copy).with(language_root_to_copy_from, { language_id: "2", language_code: "de" })
          post copy_language_tree_admin_pages_path(params)
        end

        it "should copy all childs of the original page over to the new created one" do
          expect_any_instance_of(described_class).
            to receive(:language_root_to_copy_from) { language_root_to_copy_from }
          expect_any_instance_of(described_class).
            to receive(:copy_of_language_root) { copy_of_language_root }
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
        let(:clipboard) { [{ "id" => page.id.to_s }] }
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

        it "should publish the page" do
          expect {
            post publish_admin_page_path(page)
          }.to change { page.reload.published_at }
        end
      end

      describe "#fold" do
        let(:page) { create(:alchemy_page) }

        before do
          allow(Page).to receive(:find).and_return(page)
          allow(page).to receive(:editable_by?).with(user).and_return(true)
        end

        context "if page is currently not folded" do
          before { allow(page).to receive(:folded?).and_return(false) }

          it "should fold the page" do
            expect(page).to receive(:fold!).with(user.id, true).and_return(true)
            post fold_admin_page_path(page), xhr: true
          end
        end

        context "if page is already folded" do
          before { allow(page).to receive(:folded?).and_return(true) }

          it "should unfold the page" do
            expect(page).to receive(:fold!).with(user.id, false).and_return(true)
            post fold_admin_page_path(page), xhr: true
          end
        end
      end

      describe "#unlock" do
        subject { post unlock_admin_page_path(page), xhr: true }

        let(:page) { create(:alchemy_page, name: "Best practices") }

        before do
          allow(Page).to receive(:find).with(page.id.to_s).and_return(page)
          allow(page).to receive(:editable_by?).with(user).and_return(true)
          allow(Page).to receive(:from_current_site).and_return(double(locked_by: nil))
          expect(page).to receive(:unlock!) { true }
        end

        it "should unlock the page" do
          is_expected.to eq(200)
        end

        context "requesting for html format" do
          subject { post unlock_admin_page_path(page) }

          it "should redirect to admin_pages_path" do
            is_expected.to redirect_to(admin_pages_path)
          end

          context "if passing :redirect_to through params" do
            subject { post unlock_admin_page_path(page, redirect_to: "this/path") }

            it "should redirect to the given path" do
              is_expected.to redirect_to("this/path")
            end
          end
        end
      end
    end
  end
end
