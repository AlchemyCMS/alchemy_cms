require 'spec_helper'

describe "Admin page sorting" do
  let!(:alchemy_page) { create(:alchemy_page) }

  before do
    authorize_user(:as_admin)
  end

  specify 'a sorting description is displayed to the user' do
    visit sort_admin_pages_path
    expect(page).to have_content(Alchemy.t(:explain_sitemap_dragndrop_sorting))
  end

  specify 'links to fold or edit the page and all action icons are hidden', :aggregate_failures do
    visit sort_admin_pages_path
    expect(page).to_not have_selector('.page_folder')
    expect(page).to_not have_selector('.sitemap_pagename_link')
    expect(page).to_not have_selector('.sitemap_tool')
  end
end
