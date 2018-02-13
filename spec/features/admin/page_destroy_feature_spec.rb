# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe "Page destroy feature", js: true do
    before { authorize_user(:as_admin) }

    context 'destroying a content page' do
      let!(:content_page) { create(:alchemy_page) }

      it "deletes page and redirects to page tree" do
        visit admin_pages_path

        page.find("a[href='#{admin_page_path(content_page.id)}']").click

        within '.alchemy-dialog-buttons' do
          click_button 'Yes'
        end

        expect(page.current_path).to eq admin_pages_path
        expect(page).to_not have_css "#page_#{content_page.id}"
      end
    end

    context 'destroying a layout page' do
      let!(:layout_page) { create(:alchemy_page, :layoutpage) }

      it "deletes page and redirects to layoutpages list" do
        visit admin_layoutpages_path

        page.find("a[href='#{admin_page_path(layout_page.id)}']").click

        within '.alchemy-dialog-buttons' do
          click_button 'Yes'
        end

        expect(page.current_path).to eq admin_layoutpages_path
        expect(page).to_not have_css "#page_#{layout_page.id}"
      end
    end
  end
end
