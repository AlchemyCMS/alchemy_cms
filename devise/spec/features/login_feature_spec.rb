require 'spec_helper'

describe "Login: " do
  context "If user is present" do
    let!(:user) do
      Alchemy::User.create!(
        login: 'admin',
        email: 'admin@example.com',
        password: 's3cr3t',
        password_confirmation: 's3cr3t',
        alchemy_roles: %w[admin]
      )
    end

    let!(:default_key) { Devise.authentication_keys }

    before do
      allow(Alchemy::User).to receive_messages(count: 1)
    end

    context "with Alchemy configuration" do
      it "displays an login authentication field" do
        visit '/admin/login'
        expect(page).to have_field('user_login')
      end

      it "works" do
        visit '/admin/login'
        fill_in 'user_login', with: user.login
        fill_in 'user_password', with: user.password
        click_button 'Login'
        expect(page).to have_content('Welcome back admin')
      end
    end

    context "with default Devise configuration" do
      before do
        Devise.authentication_keys = [:email]
      end

      it "displays an email authentication field" do
        visit '/admin/login'
        expect(page).to have_field('user_email')
      end

      it "works" do
        visit '/admin/login'
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: user.password
        click_button 'Login'
        expect(page).to have_content('Welcome back admin')
      end

      after do
        Devise.authentication_keys = default_key
      end
    end
  end
end
