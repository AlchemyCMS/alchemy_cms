require 'spec_helper'

describe "Login: " do
  context "If users present" do
    let!(:default_key) { Devise.authentication_keys }

    before do
      allow(Alchemy::User).to receive_messages(count: 1)
    end

    context "with Alchemy configuration" do
      it "displays an login authentication field" do
        visit '/admin/login'
        expect(page).to have_field('user_login')
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

      after do
        Devise.authentication_keys = default_key
      end
    end
  end
end
