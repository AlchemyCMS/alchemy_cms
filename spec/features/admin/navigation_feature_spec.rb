require 'spec_helper'

describe 'Admin navigation feature' do

  context 'admin users' do
    before { authorize_user(:as_admin) }

    it "can leave the admin area" do
      visit ('/admin/leave')
      expect(page).to have_content('You are about to leave Alchemy')
    end
  end
end
