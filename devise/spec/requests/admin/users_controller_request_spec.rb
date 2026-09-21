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

  context "with a request that grants an Alchemy role" do
    it "asks for the password of the acting user instead of granting the role" do
      post admin_users_path, params: {user: attributes_for(:alchemy_user).merge(alchemy_roles: ["admin"])}

      expect(response).to be_unprocessable
      expect(response.body).to include(%(name="user[current_password]"))
      expect(response.body).to include("is required to change roles")
      expect(Alchemy::User.alchemy_admins.count).to eq(1)
    end

    it "keeps the whole form when creating, because the passwords have to be entered again" do
      post admin_users_path, params: {user: attributes_for(:alchemy_user).merge(alchemy_roles: ["admin"])}

      expect(response.body).to include(%(<alchemy-message type="info">))
      expect(response.body).to include(%(id="user_email"))
      expect(response.body).to include(%(id="user_alchemy_roles"))
      expect(response.body).to include(%(id="user_password"))
    end

    it "reduces the form to the password confirmation when only the roles change" do
      member = create(:alchemy_member_user)

      patch admin_user_path(member), params: {user: {alchemy_roles: ["admin"]}}

      expect(response.body).to include(%(<alchemy-message type="info">))
      expect(response.body).to include(%(name="user[alchemy_roles][]"))
      expect(response.body).to_not include(%(id="user_email"))
      expect(response.body).to_not include(%(id="user_alchemy_roles"))
    end

    it "keeps the whole form when the edited user's password changes too" do
      member = create(:alchemy_member_user)

      patch admin_user_path(member), params: {
        user: {alchemy_roles: ["admin"], password: "n3wp4ssw0rd", password_confirmation: "n3wp4ssw0rd"}
      }

      expect(response.body).to include(%(id="user_email"))
      expect(response.body).to include(%(id="user_current_password"))
    end

    it "names the role that the confirmation is about" do
      post admin_users_path, params: {user: attributes_for(:alchemy_user).merge(alchemy_roles: ["admin"])}

      expect(response.body).to include("Administrator")
    end

    it "names the user whose roles are being changed" do
      member = create(:alchemy_member_user, firstname: "Mallory", lastname: "Newadmin")

      patch admin_user_path(member), params: {user: {alchemy_roles: ["admin"]}}

      expect(response.body).to include("Mallory Newadmin")
    end

    it "names the role when it is revoked, not only when it is granted" do
      other_admin = create(:alchemy_admin_user)

      patch admin_user_path(other_admin), params: {user: {alchemy_roles: [""]}}

      expect(response.body).to include("Administrator")
    end

    it "asks only for the acting password when changing roles of an existing user" do
      member = create(:alchemy_member_user)

      patch admin_user_path(member), params: {user: {alchemy_roles: ["admin"]}}

      expect(response.body).to include(%(id="user_current_password"))
      expect(response.body).to_not include(%(id="user_password"))
    end

    it "keeps asking for the password when the user is invalid for another reason" do
      existing_user = create(:alchemy_user)

      post admin_users_path, params: {
        user: attributes_for(:alchemy_user).merge(
          email: existing_user.email, alchemy_roles: ["admin"], current_password: "s3cr3t"
        )
      }

      expect(response).to be_unprocessable
      # The full form comes back so the other error is visible and fixable
      expect(response.body).to include(%(id="user_email"))
      expect(response.body).to include(%(name="user[current_password]"))
    end

    it "grants the role once the password is confirmed" do
      post admin_users_path, params: {
        user: attributes_for(:alchemy_user).merge(alchemy_roles: ["admin"], current_password: "s3cr3t")
      }

      expect(Alchemy::User.alchemy_admins.count).to eq(2)
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
