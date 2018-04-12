# frozen_string_literal: true

require 'spec_helper'

describe "Modules" do
  context "A custom module with a main-apps controller" do
    before { authorize_user(:as_admin) }

    it "should have a button in main_navigation, pointing to the configured controller" do
      visit '/admin'
      within '#main_navi' do
        first('a', text: 'Events').click
      end
      within '#main_content' do
        expect(page).to have_content('0 Events')
      end
    end
  end
end
