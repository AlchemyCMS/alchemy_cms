require 'spec_helper'
require 'cancan/matchers'

describe Alchemy::Permissions do
  subject { ability }

  let(:ability) { Alchemy::Devise::Ability.new(user) }

  context "A guest user" do
    let(:user) { nil }

    it "can not see any user records" do
      should_not be_able_to(:read, Alchemy.user_class)
    end
  end

  context "A member" do
    let(:user)         { build_stubbed(:alchemy_member_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can only update its own user record" do
      should be_able_to(:update, user)
      should_not be_able_to(:update, another_user)
    end

    it "can see its own record" do
      should be_able_to(:read, user)
    end
  end

  context "An author" do
    let(:user)         { build_stubbed(:alchemy_author_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can only update its own user record" do
      should be_able_to(:update, user)
      should_not be_able_to(:update, another_user)
    end

    it "can see its own record" do
      should be_able_to(:read, user)
    end
  end

  context "An editor" do
    let(:user)         { build_stubbed(:alchemy_editor_user) }
    let(:another_user) { build_stubbed(:alchemy_member_user) }

    it "can see all users" do
      should be_able_to(:read, Alchemy.user_class)
    end

    it "can only update its own user record" do
      should be_able_to(:update, user)
      should_not be_able_to(:update, another_user)
    end
  end

  context "An admin" do
    let(:user) { build_stubbed(:alchemy_admin_user) }

    it "can manage users" do
      should be_able_to(:manage, Alchemy.user_class)
    end
  end
end
