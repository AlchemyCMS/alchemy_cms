# frozen_string_literal: true

require 'spec_helper'

describe 'Admin navigation feature' do
  context 'admin users' do
    before { authorize_user(:as_admin) }

    it "can leave the admin area" do
      visit '/admin/leave'
      expect(page).to have_content('You are about to leave Alchemy')
    end
  end

  context 'editor users' do
    before { authorize_user(:as_editor) }

    it "can access the languages page" do
      visit '/admin'
      click_on 'Languages'
      expect(current_path).to eq('/admin/languages')
    end
  end
end
