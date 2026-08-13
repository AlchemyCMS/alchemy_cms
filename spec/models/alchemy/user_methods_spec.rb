# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::UserMethods do
  let(:user) { build_stubbed(:alchemy_dummy_user) }

  it "should have at least member role" do
    expect(user.alchemy_roles).not_to be_blank
    expect(user.alchemy_roles).to include("member")
  end

  describe "validations" do
    it "should validate alchemy_roles" do
      user.alchemy_roles = nil
      expect(user).not_to be_valid
      expect(user.errors[:alchemy_roles]).to include("can't be blank")
    end

    it "should validate alchemy_roles inclusion" do
      user.alchemy_roles = ["invalid_role"]
      expect(user).not_to be_valid
      expect(user.errors[:alchemy_roles]).to include("is not included in #{Alchemy.config.user_roles.join(", ")}")
    end
  end

  describe "scopes" do
    let!(:user) { create(:alchemy_dummy_user, :as_admin) }

    describe ".alchemy_admins" do
      let!(:member) { create(:alchemy_dummy_user, alchemy_roles: "member") }

      it "should only return users with admin role" do
        expect(Alchemy.config.user_class.alchemy_admins).to include(user)
        expect(Alchemy.config.user_class.alchemy_admins).not_to include(member)
      end
    end

    describe ".with_alchemy_role" do
      [:editor, "Author", :Admin].each do |role|
        context "with role #{role}" do
          it "should return users with #{role.to_s.downcase} role" do
            user = create(:alchemy_dummy_user, alchemy_roles: role.to_s.downcase)
            expect(Alchemy.config.user_class.with_alchemy_role(role)).to include(user)
          end
        end
      end

      context "with users having multiple roles" do
        it "should return users with given role at the end" do
          user = create(:alchemy_dummy_user, alchemy_roles: "admin member")
          expect(Alchemy.config.user_class.with_alchemy_role("member")).to include(user)
        end

        it "should return users with given role at the start" do
          user = create(:alchemy_dummy_user, alchemy_roles: "member admin")
          expect(Alchemy.config.user_class.with_alchemy_role("member")).to include(user)
        end

        it "should return users with given role in the middle" do
          user = create(:alchemy_dummy_user, alchemy_roles: "editor member admin")
          expect(Alchemy.config.user_class.with_alchemy_role("member")).to include(user)
        end
      end

      context "with unknown role" do
        it "logs a warning but still runs the query" do
          expect(Alchemy::Logger).to receive(:warn).with("Unknown Alchemy role: \"unknown role\"")
          expect(Alchemy.config.user_class.with_alchemy_role("Unknown role")).to be_empty
        end
      end
    end
  end

  describe ".human_alchemy_rolename" do
    it "return a translated role name" do
      expect(Alchemy.config.user_class.human_alchemy_rolename("member")).to eq("Member")
    end
  end

  describe "#human_alchemy_roles" do
    it "should return a humanized roles string." do
      user.alchemy_roles = ["member", "admin"]
      expect(user.human_alchemy_roles).to eq("Member and Administrator")
    end
  end

  describe "#has_alchemy_role?" do
    context "with given role" do
      it "should return true." do
        expect(user.has_alchemy_role?("member")).to be_truthy
      end
    end

    context "with role given as symbol" do
      it "should return true." do
        expect(user.has_alchemy_role?(:member)).to be_truthy
      end
    end

    context "without given role" do
      it "should return true." do
        expect(user.has_alchemy_role?("admin")).to be_falsey
      end
    end
  end

  describe "#alchemy_roles" do
    it "should return an array of user roles" do
      expect(user.alchemy_roles).to eq(["member"])
    end
  end

  describe "#alchemy_roles=" do
    it "should accept a single user role" do
      user.alchemy_roles = "admin"
      expect(user.alchemy_roles).to eq(["admin"])
    end

    it "should accept an array of user roles" do
      user.alchemy_roles = ["admin"]
      expect(user.alchemy_roles).to eq(["admin"])
    end

    it "should accept a string of space separated user roles" do
      user.alchemy_roles = "admin member"
      expect(user.alchemy_roles).to eq(["admin", "member"])
    end

    it "should store the user roles as space seperated string" do
      user.alchemy_roles = ["admin", "member"]
      expect(user.read_attribute(:alchemy_roles)).to eq("admin member")
    end

    it "should strip user roles" do
      user.alchemy_roles = ["admin ", " member"]
      expect(user.read_attribute(:alchemy_roles)).to eq("admin member")
    end
  end

  describe "#locked_pages" do
    let(:user) { create(:alchemy_dummy_user) }
    let(:page) { create(:alchemy_page) }

    it "should return all pages that are locked by user" do
      user.save!
      page.lock_to!(user)
      expect(user.locked_pages).to include(page)
    end
  end

  describe "#unlock_pages" do
    let(:user) { create(:alchemy_dummy_user) }
    let(:page) { create(:alchemy_page) }

    before do
      page.lock_to!(user)
    end

    it "should unlock all users lockes pages" do
      user.unlock_pages!
      expect(user.locked_pages.reload).to be_empty
    end
  end

  describe "#alchemy_admin?" do
    it "should return true if the user has admin role" do
      user.alchemy_roles = "admin"
      expect(user.alchemy_admin?).to be_truthy
    end
  end
end
