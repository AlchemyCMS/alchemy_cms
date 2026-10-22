require "rails_helper"

describe "Login: " do
  context "If user is present" do
    let!(:user) do
      Alchemy::User.create!(
        login: "admin",
        email: "admin@example.com",
        password: "s3cr3t",
        password_confirmation: "s3cr3t",
        alchemy_roles: %w[admin]
      )
    end

    let!(:default_key) { Devise.authentication_keys }

    before do
      allow(Alchemy::User).to receive_messages(count: 1)
    end

    context "with Alchemy configuration" do
      it "displays an login authentication field" do
        visit "/admin/login"
        expect(page).to have_css("#user_login[required][autocomplete='username']")
        expect(page).to have_css("#user_password[required][autocomplete='current-password']")
      end

      it "works" do
        visit "/admin/login"
        fill_in "user_login", with: user.login
        fill_in "user_password", with: user.password
        click_button "Login"
        expect(page).to have_content("Welcome back admin")
      end
    end

    context "with default Devise configuration" do
      before do
        Devise.authentication_keys = [:email]
      end

      it "displays an email authentication field" do
        visit "/admin/login"
        expect(page).to have_css("#user_email[type='email'][required][autocomplete='email']")
        expect(page).to have_css("#user_password[required][autocomplete='current-password']")
      end

      it "works" do
        visit "/admin/login"
        fill_in "user_email", with: user.email
        fill_in "user_password", with: user.password
        click_button "Login"
        expect(page).to have_content("Welcome back admin")
      end

      after do
        Devise.authentication_keys = default_key
      end
    end

    context "with rememberable Devise module enabled" do
      before do
        allow_any_instance_of(Devise::Mapping).to receive(:rememberable?).and_return(true)
      end

      it "displays a remember me checkbox" do
        visit "/admin/login"
        expect(page).to have_css("label input#user_remember_me[checked]")
        expect(page).to have_content("Remember me for 14 days")
      end
    end

    context "with rememberable Devise module disabled" do
      before do
        allow_any_instance_of(Devise::Mapping).to receive(:rememberable?).and_return(false)
      end

      it "does not display a remember me checkbox" do
        visit "/admin/login"
        expect(page).to have_css(":not(:has(input#user_remember_me))")
        expect(page).to_not have_content("Remember me for 14 days")
      end
    end
  end
end
