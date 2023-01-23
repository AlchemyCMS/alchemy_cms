# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page editing feature", type: :system do
  let(:a_page) { create(:alchemy_page) }

  context "as author" do
    before { authorize_user(:as_author) }

    it "cannot publish page." do
      visit alchemy.edit_admin_page_path(a_page)
      expect(page).to have_selector("#publish_page_form button[disabled]")
    end

    describe "the preview frame", :js do
      it "has relative url" do
        visit alchemy.edit_admin_page_path(a_page)
        expect(page).to have_selector("iframe[src='#{admin_page_path(a_page)}']")
      end
    end

    describe "single preview source", :js do
      it "does not show as select" do
        visit alchemy.edit_admin_page_path(a_page)
        expect(page).to_not have_select("preview_url")
      end
    end

    describe "multiple preview sources", :js do
      class FooPreviewSource < Alchemy::Admin::PreviewUrl; end

      around do |example|
        Alchemy.preview_sources << FooPreviewSource
        example.run
        Alchemy.instance_variable_set(:@_preview_sources, nil)
      end

      it "show as select" do
        visit alchemy.edit_admin_page_path(a_page)
        expect(page).to have_select("preview_url", options: ["Internal", "Foo Preview"])
      end
    end
  end

  context "as editor" do
    before { authorize_user(:as_editor) }

    it "can publish page." do
      visit alchemy.edit_admin_page_path(a_page)
      find("#publish_page_form button").click
      expect(page).to have_content Alchemy.t(:page_published, name: a_page.name)
    end

    context "while editing a global page" do
      let(:a_page) { create(:alchemy_page, :layoutpage) }

      it "can publish page." do
        visit alchemy.edit_admin_page_path(a_page)
        expect(page).to have_selector("#publish_page_form")
      end
    end

    it "can create a new element", :js do
      visit alchemy.edit_admin_page_path(a_page)
      expect(page).to have_link("New element")
      click_link("New element")
      expect(page).to have_selector(".alchemy-dialog-body .simple_form")
      within ".alchemy-dialog-body .simple_form" do
        select2("Article", from: "Element")
        click_button("Add")
      end
      expect(page).to_not have_selector(".alchemy-dialog-body")
      expect(page).to have_selector('.element-editor[data-element-name="article"]')
    end
  end

  context "as admin" do
    let(:a_page) { create(:alchemy_page, :public) }

    before { authorize_user(:as_admin) }

    context "in configure overlay" do
      context "when editing a normal page" do
        it "should show all relevant input fields" do
          visit alchemy.configure_admin_page_path(a_page)
          expect(page).to have_selector("input#page_urlname")
          expect(page).to have_selector("input#page_title")
          expect(page).to have_selector("input#page_robot_index")
          expect(page).to have_selector("input#page_robot_follow")
        end

        context "with sitemaps show_flag config option set to true" do
          before do
            stub_alchemy_config(:sitemap, { "show_flag" => true })
          end

          it "should show sitemap checkbox" do
            visit alchemy.configure_admin_page_path(a_page)
            expect(page).to have_selector('input[type="checkbox"]#page_sitemap')
          end
        end

        context "with sitemaps show_flag config option set to false" do
          before do
            stub_alchemy_config(:sitemap, { "show_flag" => false })
          end

          it "should not show sitemap checkbox" do
            visit alchemy.configure_admin_page_path(a_page)
            expect(page).to_not have_selector('input[type="checkbox"]#page_sitemap')
          end
        end

        context "enable_searchable" do
          before do
            Alchemy.enable_searchable = searchable
            visit alchemy.configure_admin_page_path(a_page)
          end

          # reset default value
          after { Alchemy.enable_searchable = false }

          context "is enabled" do
            let(:searchable) { true }

            it "should show searchable checkbox" do
              expect(page).to have_selector('input[type="checkbox"]#page_searchable')
            end
          end

          context "is disabled" do
            let(:searchable) { false }

            it "should not show searchable checkbox" do
              visit alchemy.configure_admin_page_path(a_page)
              expect(page).to_not have_selector('input[type="checkbox"]#page_searchable')
            end
          end
        end
      end

      context "when editing a global page" do
        let(:layout_page) { create(:alchemy_page, :layoutpage) }

        it "should not show the input fields for normal pages" do
          visit alchemy.edit_admin_layoutpage_path(layout_page)
          expect(page).to_not have_selector("input#page_urlname")
          expect(page).to_not have_selector("input#page_title")
          expect(page).to_not have_selector("input#page_robot_index")
          expect(page).to_not have_selector("input#page_robot_follow")
        end
      end

      it "should show the tag_list input field" do
        visit alchemy.configure_admin_page_path(a_page)
        expect(page).to have_selector("input#page_tag_list")
      end
    end

    context "in preview frame" do
      it "the menubar does not render on the page" do
        visit alchemy.admin_page_path(a_page)
        expect(page).not_to have_selector("#alchemy_menubar")
      end

      context "with menu available" do
        let!(:menu) { create(:alchemy_node, name: "main_menu") }
        let!(:node) { create(:alchemy_node, url: "/page-1", parent: menu) }

        it "navigation links are not clickable" do
          visit alchemy.admin_page_path(a_page)
          within("nav") do
            expect(page).to have_selector('a[href="javascript: void(0)"]')
          end
        end
      end
    end

    context "in element panel" do
      let!(:everything_page) do
        create(:alchemy_page, page_layout: "everything", autogenerate_elements: true)
      end

      it "renders editors for all element ingredients" do
        visit alchemy.admin_elements_path(page_version_id: everything_page.draft_version.id)

        expect(page).to have_selector("div.ingredient-editor.boolean")
        expect(page).to have_selector("div.ingredient-editor.datetime")
        expect(page).to have_selector("div.ingredient-editor.file")
        expect(page).to have_selector("div.ingredient-editor.html")
        expect(page).to have_selector("div.ingredient-editor.link")
        expect(page).to have_selector("div.ingredient-editor.picture")
        expect(page).to have_selector("div.ingredient-editor.richtext")
        expect(page).to have_selector("div.ingredient-editor.select")
        expect(page).to have_selector("div.ingredient-editor.text")
      end

      it "renders data attribute based on ingredient role" do
        visit alchemy.admin_elements_path(page_version_id: everything_page.draft_version.id)

        expect(page).to have_selector("div[data-ingredient-role=boolean]")
        expect(page).to have_selector("div[data-ingredient-role=datetime]")
        expect(page).to have_selector("div[data-ingredient-role=file]")
        expect(page).to have_selector("div[data-ingredient-role=html]")
        expect(page).to have_selector("div[data-ingredient-role=link]")
        expect(page).to have_selector("div[data-ingredient-role=picture]")
        expect(page).to have_selector("div[data-ingredient-role=richtext]")
        expect(page).to have_selector("div[data-ingredient-role=select]")
        expect(page).to have_selector("div[data-ingredient-role=text]")
      end
    end
  end

  describe "configure properties", js: true do
    before { authorize_user(:as_admin) }
    let!(:a_page) { create(:alchemy_page) }

    before do
      visit alchemy.admin_pages_path
      find(".sitemap_page[name='#{a_page.name}'] .icon.fa-cog").click
      expect(page).to have_selector(".alchemy-dialog-overlay.open")
    end

    context "when updating the name" do
      it "saves the name" do
        within(".alchemy-dialog.modal") do
          find("input#page_name").set("name with some %!x^)'([@!{}]|/?\:# characters")
          find(".submit button").click
        end
        expect(page).to_not have_selector(".alchemy-dialog-overlay.open")
        expect(page).to have_selector("#sitemap a.sitemap_pagename_link", text: "name with some %!x^)'([@!{}]|/?\:# characters")
      end
    end

    describe "changing parent" do
      let!(:new_parent) { create(:alchemy_page) }

      it "can change page parent" do
        within(".alchemy-dialog.modal") do
          expect(page).to have_css("#s2id_page_parent_id")
          select2_search(new_parent.name, from: "Parent")
          find(".submit button").click
        end
        expect(page).to_not have_selector(".alchemy-dialog-overlay.open")
        expect(page).to have_selector("#sitemap .sitemap_url", text: "/#{new_parent.urlname}/#{a_page.urlname}")
      end
    end
  end

  describe "fixed attributes" do
    before { authorize_user(:as_author) }

    context "when page has fixed attributes" do
      let!(:readonly_page) do
        create(:alchemy_page, page_layout: "readonly")
      end

      it "is not possible to edit the attribute", :aggregate_failures do
        visit alchemy.configure_admin_page_path(readonly_page)
        readonly_page.fixed_attributes.all.each do |attribute, _v|
          expect(page).to have_selector("#page_#{attribute}[disabled=\"disabled\"]")
        end
      end
    end
  end
end
