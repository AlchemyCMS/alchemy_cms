require 'spec_helper'

module Alchemy
  describe "Page creation" do
    before { authorize_user(:as_admin) }

    describe "overlay GUI" do
      context "without having a Page in the clipboard" do
        it "does not contain tabs" do
          visit new_admin_page_path
          within('#main_content') { expect(page).to_not have_selector('#overlay_tabs') }
        end
      end

      context "when having a Page in the clipboard" do
        before do
          expect(Page).to receive(:all_from_clipboard_for_select).and_return [build_stubbed(:page)]
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
