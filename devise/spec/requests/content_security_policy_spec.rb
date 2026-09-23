# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy" do
  # Without a user the login page redirects into the signup form, and we want
  # the policy of the rendered page here.
  before { create(:alchemy_admin_user) }

  def policy = response.headers["Content-Security-Policy"]

  it "is sent with the login page" do
    get "/admin/login"
    expect(response).to have_http_status(:ok)
    expect(policy).to be_present
  end

  it "is sent with the password reset page" do
    get "/admin/passwords"
    expect(response).to have_http_status(:ok)
    expect(policy).to be_present
  end
end
