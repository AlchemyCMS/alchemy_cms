# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Layoutpages", type: :system do
  let!(:language) { create(:alchemy_language) }
  let!(:layoutpage) { create(:alchemy_page, :layoutpage, name: "Footer") }

  before do
    authorize_user(:as_admin)
  end

  it "can copy a layoutpage into the clipboard", :js do
    visit alchemy.admin_layoutpages_path

    within "#page_#{layoutpage.id}" do
      find("alchemy-icon[name='file-copy']").click
    end

    expect(page).to have_content("Copied #{layoutpage.name} to clipboard")
    expect(page).to have_css("alchemy-icon[name='clipboard'][icon-style='fill']")
  end
end
