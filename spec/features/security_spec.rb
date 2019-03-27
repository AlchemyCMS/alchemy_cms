# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Security.", type: :system do
  context "If user is not logged in" do
    it "should see login form" do
      visit '/admin/dashboard'
      expect(current_path).to eq(Alchemy.login_path)
    end
  end

  context "If ssl is enforced" do
    before do
      allow_any_instance_of(Alchemy::BaseController)
        .to receive(:ssl_required?)
        .and_return(true)
      authorize_user(:as_admin)
    end

    it "redirects every request to https." do
      visit '/admin/dashboard'
      expect(current_url).to eq('https://127.0.0.1/admin/dashboard')
    end
  end
end
