require "rails_helper"

describe "Password reset feature." do
  let(:user) { create(:alchemy_admin_user) }

  it "User can visit password reset form." do
    visit admin_new_password_path

    expect(page).to have_content("Password reset")
  end

  it "User can request password reset." do
    visit admin_new_password_path

    fill_in :user_email, with: user.email
    click_button "Send reset instructions"

    expect(page)
      .to have_content("You will receive an email with instructions on how to reset your password in a few minutes.")
  end

  it "User can change password." do
    allow(Alchemy::User)
      .to receive(:reset_password_by_token)
      .and_return(user)

    visit admin_edit_password_path(id: user.id, reset_password_token: "1234")

    fill_in :user_password, with: "secret123"
    fill_in :user_password_confirmation, with: "secret123"
    click_button "Change password"

    expect(page)
      .to have_content("Your password has been changed successfully.")
  end
end
