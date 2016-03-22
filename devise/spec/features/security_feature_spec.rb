require 'spec_helper'

describe "Security: " do
  context "If user is present" do
    before { allow(Alchemy::User).to receive_messages(:count => 1) }

    it "a visitor should not be able to signup" do
      visit '/admin/signup'
      within('#alchemy_greeting') { expect(page).not_to have_content('have to signup') }
    end

    context "that is not logged in" do
      it "should see login form" do
        visit '/admin/dashboard'
        expect(current_path).to eq('/admin/login')
      end
    end
  end
end
