require "rails_helper"

RSpec.describe Alchemy::Admin::UsersController, type: :request do
  before do
    authorize_user create(:alchemy_admin_user)
  end

  context "with error happening while sending mail" do
    before do
      allow_any_instance_of(Alchemy::Admin::BaseController)
        .to receive(:raise_exception?) { false }
      allow_any_instance_of(Alchemy::User)
        .to receive(:deliver_welcome_mail) { raise(Net::SMTPAuthenticationError) }
    end

    context "on create" do
      it "does not raise DoubleRender error" do
        expect {
          post admin_users_path, params: {user: attributes_for(:alchemy_user).merge(send_credentials: "1")}
        }.to_not raise_error
      end
    end

    context "on update" do
      it "does not raise DoubleRender error" do
        user = create(:alchemy_member_user)
        expect {
          patch admin_user_path(user), params: {user: {send_credentials: "1"}}
        }.to_not raise_error
      end
    end
  end

  context "with Alchemy.admin_path customised" do
    before(:all) do
      Alchemy.admin_path = "/backend"
      Rails.application.reload_routes!
    end

    it "uses the custom admin path" do
      expect(admin_users_path).to eq("/backend/users")
    end

    after(:all) do
      Alchemy.admin_path = "/admin"
      Rails.application.reload_routes!
    end
  end
end
