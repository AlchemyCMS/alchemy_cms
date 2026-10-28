require "rails_helper"
require "cancan/matchers"

describe Alchemy::Permissions do
  subject { ability }

  let(:ability) { Alchemy::Devise::Ability.new(user) }

  context "A guest user" do
    let(:user) { nil }

    it "can not see any user records" do
      is_expected.not_to be_able_to(:read, Alchemy.config.user_class)
    end

    it "can signup user" do
      is_expected.to be_able_to(:signup, Alchemy.config.user_class)
    end

    context "if no user is present" do
      before { expect(Alchemy::User).to receive(:count).and_return(0) }

      it "can create user" do
        is_expected.to be_able_to(:create, Alchemy.config.user_class)
      end
    end

    context "if user is present" do
      before { expect(Alchemy::User).to receive(:count).and_return(1) }

      it "cannot create user" do
        is_expected.to_not be_able_to(:create, Alchemy.config.user_class)
      end
    end
  end

  context "A member" do
    let(:user) { build_stubbed(:alchemy_member_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end

    it "can only see its own record" do
      is_expected.to be_able_to(:show, user)
      is_expected.not_to be_able_to(:show, another_user)
    end

    it "cannot see other user records" do
      is_expected.to_not be_able_to(:index, Alchemy.config.user_class)
    end
  end

  context "An author" do
    let(:user) { build_stubbed(:alchemy_author_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end

    it "can only see its own record" do
      is_expected.to be_able_to(:show, user)
      is_expected.not_to be_able_to(:show, another_user)
    end
  end

  context "An editor" do
    let(:user) { build_stubbed(:alchemy_editor_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can see all users" do
      is_expected.to be_able_to(:read, Alchemy.config.user_class)
    end

    it "can only update its own user record" do
      is_expected.to be_able_to(:update, user)
      is_expected.not_to be_able_to(:update, another_user)
    end
  end

  context "An admin" do
    let(:user) { build_stubbed(:alchemy_admin_user) }
    let(:member) { build_stubbed(:alchemy_member_user) }

    it "can manage users" do
      is_expected.to be_able_to(:manage, Alchemy.config.user_class)
    end

    it "cannot impersonate users by default" do
      is_expected.not_to be_able_to(:impersonate, member)
    end

    context "with user impersonation enabled" do
      before { stub_config(Alchemy::Devise.config, user_impersonation: true) }

      it "can impersonate an active non-admin user" do
        is_expected.to be_able_to(:impersonate, member)
      end

      it "cannot impersonate itself" do
        is_expected.not_to be_able_to(:impersonate, user)
      end

      it "cannot impersonate another administrator" do
        is_expected.not_to be_able_to(:impersonate, build_stubbed(:alchemy_admin_user))
      end

      it "cannot impersonate an inactive user" do
        allow(member).to receive(:active_for_authentication?).and_return(false)

        is_expected.not_to be_able_to(:impersonate, member)
      end
    end
  end

  context "A non-admin with user impersonation enabled" do
    let(:user) { build_stubbed(:alchemy_member_user) }

    before { stub_config(Alchemy::Devise.config, user_impersonation: true) }

    it "cannot impersonate another user" do
      is_expected.not_to be_able_to(:impersonate, build_stubbed(:alchemy_member_user))
    end
  end
end
