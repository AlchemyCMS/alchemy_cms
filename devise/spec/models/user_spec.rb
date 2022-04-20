require "rails_helper"

module Alchemy
  describe User do
    let(:user) { build_stubbed(:alchemy_user) }
    let(:page) { build_stubbed(:alchemy_page) }

    it "should have at least member role" do
      expect(user.alchemy_roles).not_to be_blank
      expect(user.alchemy_roles).to include("member")
    end

    describe ".search" do
      subject { User.search(query) }

      let!(:user1) do
        create :alchemy_user,
          email: "find@me.com",
          login: "user1",
          firstname: "Michael",
          lastname: "Jackson"
      end

      let!(:user2) do
        create :alchemy_user,
          email: "find@me-not.com",
          login: "user2",
          firstname: "Prince Rogers",
          lastname: "Nelson"
      end

      let!(:users) do
        [user1, user1]
      end

      context "by email" do
        let(:query) { "find@me.com" }

        it "returns all matching users" do
          is_expected.to include(user1)
          is_expected.to_not include(user2)
        end
      end

      context "by login" do
        let(:query) { "User1" }

        it "returns all matching users" do
          is_expected.to include(user1)
          is_expected.to_not include(user2)
        end
      end

      context "by firstname" do
        let(:query) { "prince" }

        it "returns all matching users" do
          is_expected.to_not include(user1)
          is_expected.to include(user2)
        end
      end

      context "by lastname" do
        let(:query) { "jackson" }

        it "returns all matching users" do
          is_expected.to include(user1)
          is_expected.to_not include(user2)
        end
      end
    end

    describe "scopes" do
      let(:user) { create(:alchemy_admin_user) }

      describe ".admins" do
        it "should only return users with admin role" do
          expect(User.admins).to include(user)
        end
      end
    end

    describe ".human_rolename" do
      it "return a translated role name" do
        expect(User.human_rolename("member")).to eq("Member")
      end
    end

    describe "#deliver_welcome_mail" do
      let(:user) { build_stubbed(:alchemy_admin_user) }

      it "delivers the admin welcome mail." do
        expect(Notifications).to receive(:alchemy_user_created)
            .and_return(OpenStruct.new(deliver: true))

        user.deliver_welcome_mail
      end

      context "of author user" do
        before { user.alchemy_roles = %w(author) }

        it "delivers the admin welcome mail." do
          expect(Notifications).to receive(:alchemy_user_created)
              .and_return(OpenStruct.new(deliver: true))

          user.deliver_welcome_mail
        end
      end

      context "of member user" do
        before { user.alchemy_roles = %w(member) }

        it "delivers the welcome mail." do
          expect(Notifications).to receive(:member_created)
              .and_return(OpenStruct.new(deliver: true))

          user.deliver_welcome_mail
        end
      end
    end

    describe "#human_roles_string" do
      it "should return a humanized roles string." do
        user.alchemy_roles = ["member", "admin"]
        expect(user.human_roles_string).to eq("Member and Administrator")
      end
    end

    describe "#role_symbols" do
      it "should return an array of user role symbols" do
        expect(user.role_symbols).to eq([:member])
      end
    end

    describe "#has_role?" do
      context "with given role" do
        it "should return true." do
          expect(user.has_role?("member")).to be_truthy
        end
      end

      context "with role given as symbol" do
        it "should return true." do
          expect(user.has_role?(:member)).to be_truthy
        end
      end

      context "without given role" do
        it "should return true." do
          expect(user.has_role?("admin")).to be_falsey
        end
      end
    end

    describe "#role" do
      context "when user doesn't have any roles" do
        before { user.alchemy_roles = [] }

        it "should return nil" do
          expect(user.role).to be_nil
        end
      end

      context "when user has multiple roles" do
        before { user.alchemy_roles = ["admin", "member"] }

        it "should return the first role" do
          expect(user.role).to eq("admin")
        end
      end
    end

    describe "#alchemy_roles" do
      it "should return an array of user roles" do
        expect(user.alchemy_roles).to eq(["member"])
      end
    end

    describe "#alchemy_roles=" do
      it "should accept an array of user roles" do
        user.alchemy_roles = ["admin"]
        expect(user.alchemy_roles).to eq(["admin"])
      end

      it "should accept a string of user roles" do
        user.alchemy_roles = "admin member"
        expect(user.alchemy_roles).to eq(["admin", "member"])
      end

      it "should store the user roles as space seperated string" do
        user.alchemy_roles = ["admin", "member"]
        expect(user.read_attribute(:alchemy_roles)).to eq("admin member")
      end
    end

    describe "#add_role" do
      it "should add the given role to roles array" do
        user.add_role "admin"
        expect(user.alchemy_roles).to eq(["member", "admin"])
      end

      it "should not add the given role twice" do
        user.add_role "member"
        expect(user.alchemy_roles).to eq(["member"])
      end
    end

    describe "#logged_in?" do
      let(:user) { build(:alchemy_user) }

      before { allow(Config).to receive(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 30.minutes.ago
        user.save!
        expect(user.logged_in?).to be_truthy
      end
    end

    describe "#logged_out?" do
      let(:user) { build(:alchemy_user) }

      before { allow(Config).to receive(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 2.hours.ago
        user.save!
        expect(user.logged_out?).to be_truthy
      end
    end

    describe "#pages_locked_by_me" do
      let(:user) { create(:alchemy_admin_user) }
      let(:page) { create(:alchemy_page) }

      before { allow(Alchemy::PageLayout).to receive(:get).and_return({}) }

      it "should return all pages that are locked by user" do
        user.save!
        page.lock_to!(user)
        expect(user.locked_pages).to include(page)
      end
    end

    describe "#unlock_pages" do
      let(:user) { create(:alchemy_user) }
      let(:page) { create(:alchemy_page) }

      before do
        page.lock_to!(user)
      end

      it "should unlock all users lockes pages" do
        user.unlock_pages!
        expect(user.locked_pages).to be_empty
      end
    end

    describe "#is_admin?" do
      it "should return true if the user has admin role" do
        user.alchemy_roles = "admin"
        expect(user.is_admin?).to be_truthy
      end
    end

    describe "#fullname" do
      it "should return the firstname and lastname" do
        expect(user.fullname).to eq("John Doe")
      end

      context "user without firstname and lastname" do
        it "should return the login" do
          user.firstname = nil
          user.lastname = nil
          expect(user.fullname).to eq(user.login)
        end
      end

      context "with flipped option set to true" do
        it "should return the lastname and firstname comma seperated" do
          expect(user.fullname(flipped: true)).to eq("Doe, John")
        end
      end

      context "with blank firstname" do
        it "should not have whitespace" do
          user.firstname = nil
          expect(user.fullname).to eq("Doe")
        end
      end
    end

    describe "#store_request_time!" do
      let(:user) { create(:alchemy_admin_user) }

      it "should store the timestamp of the request" do
        last_request_at = 2.hours.ago
        user.last_request_at = last_request_at
        user.save!
        user.store_request_time!
        expect(user.last_request_at).not_to eq(last_request_at)
      end
    end
  end
end
