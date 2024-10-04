# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page creation", type: :system do
  before { authorize_user(:as_admin) }

  describe "parent selection", :js do
    let!(:homepage) { create(:alchemy_page, :language_root) }

    context "without having a parent id in the params" do
      it "contains a parent select" do
        visit new_admin_page_path
        expect(page).to have_css("#s2id_page_parent_id")
      end
    end

    context "with having a parent id in the params" do
      it "contains a hidden parent_id field" do
        visit new_admin_page_path(parent_id: homepage)
        expect(page).to have_field("page_parent_id", type: "hidden")
        expect(page).to_not have_css("#s2id_page_parent_id")
      end
    end
    context "with same name " do
      let!(:existing_page) { create(:alchemy_page, parent: homepage, name: "Unique Name") }
      it "doesn't create a page with the same name" do
        visit admin_pages_path

        find(%(a.icon_button[href="/admin/pages/new?parent_id=#{homepage.id}"]), visible: true, match: :first).click
        select2 "Standard", from: "Type"
        fill_in "Name", with: "Unique Name"
        click_button "create"

        expect(page).to have_css("div.alchemy-dialog-body form small.error", text: "has already been taken")
      end
    end
  end

  describe "overlay GUI" do
    context "without having a Page in the clipboard" do
      it "does not contain tabs" do
        visit new_admin_page_path
        within("#main_content") { expect(page).to_not have_selector("#overlay_tabs") }
      end
    end

    context "when having a Page in the clipboard" do
      before do
        expect(Alchemy::Page).to receive(:all_from_clipboard_for_select).and_return [build_stubbed(:alchemy_page)]
      end

      it "contains tabs for creating a new page and pasting from clipboard" do
        visit new_admin_page_path
        within("#overlay_tabs") { expect(page).to have_selector "[panel='create_page_tab'], [panel='paste_page_tab']" }
      end

      context "", js: true do
        let(:root_page) { Alchemy::Page.last }

        before do
          visit admin_pages_path
          page.find("a[href='#{new_admin_page_path(parent_id: root_page.id)}']").click
        end

        it "the create page tab is visible by default" do
          within("#overlay_tabs") do
            expect(page).to have_selector("[panel='create_page_tab']", visible: true)
            expect(page).to have_selector("[panel='paste_page_tab']", visible: false)
          end
        end

        context "when clicking on an inactive tab" do
          it "shows that clicked tab" do
            within("#overlay_tabs") do
              find("[panel='paste_page_tab']").click
              expect(find("[name='create_page_tab']")).to_not be_visible
              expect(find("[name='paste_page_tab']")).to be_visible
            end
          end
        end
      end
    end
  end
end
