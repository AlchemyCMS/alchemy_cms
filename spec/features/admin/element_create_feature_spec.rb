require 'spec_helper'

describe 'element create feature', js: true do
  let(:a_page) { FactoryGirl.create(:page) }

  before do
    authorize_as_admin
    visit edit_admin_page_path(a_page)
    expect(page).to have_no_selector('.alchemy-elements-window .element_editor')
  end

  it "adds a new element to the list" do
    create_element!
    expect(page).to have_no_selector(".spinner") # wait until spinner disappears
    expect(page).to have_selector(".element_editor", count: 1)
  end
end

