# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin layout", type: :system do
  let(:user) { create(:alchemy_dummy_user, :as_admin, name: "Joe User") }

  before do
    authorize_user(user)
  end

  it "has controller and action name as body class" do
    visit admin_path
    expect(page).to have_selector("body.dashboard.index")
  end
end
