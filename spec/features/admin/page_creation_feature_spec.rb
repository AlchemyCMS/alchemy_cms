require 'spec_helper'

module Alchemy
  describe "Page creation" do
    before { authorize_user(:as_admin) }

    it "is possible to choose the parent page" do
      parent = create(:page, name: 'Parent')
      visit new_admin_page_path
      select 'Parent', from: 'page_parent_id'
      select 'Standard', from: 'page_page_layout'
      fill_in 'page_name', with: 'Child'
      click_button 'Save'
      child = Page.find_by(name: 'Child')
      expect(child.parent).to eq(parent)
    end

    it "is possible to let create a node for the page" do
      visit new_admin_page_path
      select 'Standard', from: 'page_page_layout'
      fill_in 'page_name', with: 'A page with node'
      check 'page_create_node', checked: true
      click_button 'Save'
      node_page = Page.find_by(name: 'A page with node')
      expect(node_page.nodes).to_not be_empty
    end

    describe "overlay GUI" do
      context "without having a Page in the clipboard" do
        it "does not contain tabs" do
          visit new_admin_page_path
          within('#main_content') { expect(page).to_not have_selector('#overlay_tabs') }
        end
      end

      context "when having a Page in the clipboard" do
        before do
          expect(Page).to receive(:all_from_clipboard_for_select).and_return [build_stubbed(:alchemy_page)]
        end

        it "contains tabs for creating a new page and pasting from clipboard" do
          visit new_admin_page_path
          within('#overlay_tabs') { expect(page).to have_selector '#create_page_tab, #paste_page_tab' }
        end

        context "", js: true do
          before do
            visit admin_pages_path
            page.first(:link, 'Create a new subpage').click
          end

          it "the create page tab is visible by default" do
            within('#overlay_tabs') do
              expect(find '#create_page_tab').to be_visible
              expect(find '#paste_page_tab').to_not be_visible
            end
          end

          context "when clicking on an inactive tab" do
            it "shows that clicked tab" do
              within('#overlay_tabs') do
                click_link('Paste from clipboard')
                expect(find '#create_page_tab').to_not be_visible
                expect(find '#paste_page_tab').to be_visible
              end
            end
          end
        end
      end
    end
  end
end
