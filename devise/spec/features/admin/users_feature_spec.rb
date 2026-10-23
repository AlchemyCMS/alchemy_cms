require "rails_helper"

RSpec.describe "Admin users feature." do
  shared_examples "allowing to set users language" do
    before do
      Alchemy::I18n.available_locales = [:en, :de]
    end

    it "allows to set users language" do
      subject

      expect(page).to have_selector("select#user_language")
      expect(page).to have_selector("select#user_language option[value='en']")
      expect(page).to have_selector("select#user_language option[value='de']")
    end
  end

  describe "signup user" do
    subject { visit admin_signup_path }

    it "renders signup form" do
      subject

      expect(page).to have_content("Please signup to edit your Website.")
      expect(page).to have_selector(".login_signup_box")
    end

    it_behaves_like "allowing to set users language"

    context "with login required" do
      before do
        allow_any_instance_of(Alchemy::User).to receive(:login_required?) { true }
      end

      it "requires login field" do
        visit admin_signup_path
        expect(page).to have_selector("input#user_login[required]")
      end
    end

    context "with email required" do
      before do
        allow_any_instance_of(Alchemy::User).to receive(:email_required?) { true }
      end

      it "requires email field" do
        visit admin_signup_path
        expect(page).to have_selector("input#user_email[required]")
      end
    end

    it "does not render tag list input" do
      visit admin_signup_path

      expect(page).not_to have_selector(".tag_list")
    end

    it "does not render role select" do
      visit admin_signup_path

      expect(page).not_to have_selector("#user_alchemy_roles")
    end
  end

  context "logged in as admin" do
    subject { visit new_admin_user_path }

    before { authorize_user(create(:alchemy_admin_user)) }

    describe "create new user" do
      it "has send_credentials checkbox activated" do
        subject

        expect(page).to have_selector 'input[type="checkbox"][checked="checked"][name="user[send_credentials]"]'
      end

      it "shows role select" do
        subject

        expect(page).to have_selector("#user_alchemy_roles")
      end

      it "shows tag list input" do
        subject

        expect(page).to have_selector(".tag_list")
      end

      it_behaves_like "allowing to set users language"
    end

    describe "granting a role" do
      it "carries the entered attributes through the password confirmation" do
        visit new_admin_user_path
        fill_in "user_firstname", with: "Mallory"
        fill_in "user_lastname", with: "Newadmin"
        fill_in "user_login", with: "mallory"
        fill_in "user_email", with: "mallory@example.com"
        fill_in "user_password", with: "n3wp4ssw0rd"
        fill_in "user_password_confirmation", with: "n3wp4ssw0rd"
        # Administrator on top of the preselected default, so both roles have to survive
        select "Administrator", from: "user_alchemy_roles"
        click_button "Save"

        expect(page).to have_selector("#user_current_password")
        expect(Alchemy::User.find_by(login: "mallory")).to be_nil

        fill_in "user_password", with: "n3wp4ssw0rd"
        fill_in "user_password_confirmation", with: "n3wp4ssw0rd"
        fill_in "user_current_password", with: "s3cr3t"
        click_button "Save"

        user = Alchemy::User.find_by(login: "mallory")
        expect(user).to be_present
        expect(user.firstname).to eq("Mallory")
        expect(user.lastname).to eq("Newadmin")
        expect(user.email).to eq("mallory@example.com")
        expect(user.alchemy_roles).to eq(["member", "admin"])
      end
    end

    describe "changing a role" do
      let(:member) { create(:alchemy_author_user) }

      it "carries the other edited attributes through the password confirmation" do
        visit edit_admin_user_path(member)
        fill_in "user_firstname", with: "Renamed"
        select "Administrator", from: "user_alchemy_roles"
        unselect "Author", from: "user_alchemy_roles"
        click_button "Save"

        expect(page).to have_selector("#user_current_password")
        expect(page).to_not have_selector("#user_firstname")
        expect(member.reload.alchemy_roles).to eq(["author"])

        fill_in "user_current_password", with: "s3cr3t"
        click_button "Save"

        member.reload
        expect(member.alchemy_roles).to eq(["admin"])
        expect(member.firstname).to eq("Renamed")
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
      subject { visit edit_admin_user_path(id: user.id) }

      let(:user) { create(:alchemy_author_user) }

      it "has send_credentials checkbox deactivated" do
        subject

        expect(page).to have_selector 'input[type="checkbox"][name="user[send_credentials]"]'
      end

      it_behaves_like "allowing to set users language"

      it "can set users timezone" do
        subject

        within "form.alchemy[action*='/admin/users']" do
          expect(page).to have_select "Timezone"
          select "Berlin", from: "Timezone"
          click_button "Save"
        end

        expect(page).to have_content Alchemy.t("User updated", name: user.name)
        expect(user.reload.timezone).to eq "Berlin"
      end
    end
  end
end
