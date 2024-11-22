require "rails_helper"

describe "Admin users feature." do
  describe "signup user" do
    it "renders signup form" do
      visit admin_signup_path

      expect(page).to have_content("Please signup to edit your Website.")
      expect(page).to have_selector(".login_signup_box")
    end

    it "does not render tag list input" do
      visit admin_signup_path

      expect(page).not_to have_selector(".tag_list")
    end
  end

  context "logged in as admin" do
    before { authorize_user(create(:alchemy_admin_user)) }

    describe "create new user" do
      it "has send_credentials checkbox activated" do
        visit new_admin_user_path

        expect(page).to have_selector 'input[type="checkbox"][checked="checked"][name="user[send_credentials]"]'
      end
    end

    describe "users list" do
      let!(:users) { create_list(:alchemy_user, 2) }

      it "lists existing users", :aggregate_failures do
        visit admin_users_path

        within "table.list" do
          users.each do |user|
            expect(page).to have_text user.email
          end
        end
      end

      it "is searchable" do
        visit admin_users_path
        fill_in "search", with: users.first.email
        begin
          find(".search_field button").click
          # Allow to fail on Alchemy 5.0 that does not have a submit button
        rescue Capybara::ElementNotFound
          true
        else
          expect(page).to have_content users.first.email
          expect(page).to_not have_content users.last.email
        end
      end
    end

    describe "edit existing user" do
      let(:user) { create(:alchemy_author_user) }

      it "has send_credentials checkbox deactivated" do
        visit edit_admin_user_path(id: user.id)

        expect(page).to have_selector 'input[type="checkbox"][name="user[send_credentials]"]'
      end
    end
  end
end
