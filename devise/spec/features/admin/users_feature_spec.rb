require 'spec_helper'

describe "Admin users feature." do

  describe 'signup user' do
    it "renders signup form" do
      visit admin_signup_path

      expect(page).to have_content('Please signup to edit your Website.')
      expect(page).to have_selector('.login_signup_box')
    end

    it "does not render tag list input" do
      visit admin_signup_path

      expect(page).not_to have_selector('.tag_list')
    end
  end

  context 'logged in as admin' do
    before { authorize_user(create(:alchemy_admin_user)) }

    describe 'create new user' do
      it "has send_credentials checkbox activated" do
        visit new_admin_user_path

        expect(page).to have_selector 'input[type="checkbox"][checked="checked"][name="user[send_credentials]"]'
      end
    end

    describe 'edit existing user' do
      let(:user) { create(:alchemy_author_user) }

      it "has send_credentials checkbox deactivated" do
        visit edit_admin_user_path(id: user.id)

        expect(page).to have_selector 'input[type="checkbox"][name="user[send_credentials]"]'
      end
    end
  end
end
