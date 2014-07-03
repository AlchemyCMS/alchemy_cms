require 'spec_helper'

module Alchemy
  describe User do
    let(:user) { build_stubbed(:alchemy_user) }
    let(:page) { build_stubbed(:page) }

    it "should have at least member role" do
      user.alchemy_roles.should_not be_blank
      user.alchemy_roles.should include('member')
    end

    context ".after_save" do
      let(:user) { build_stubbed(:alchemy_admin_user) }

      context "with send_credentials set to '1'" do
        before { user.send_credentials = '1' }

        it "delivers the admin welcome mail." do
          Notifications.should_receive(:alchemy_user_created).and_return(OpenStruct.new(deliver: true))
          user.save!
        end

        context "of author user" do
          before { user.alchemy_roles = %w(author) }

          it "delivers the admin welcome mail." do
            Notifications.should_receive(:alchemy_user_created).and_return(OpenStruct.new(deliver: true))
            user.save!
          end
        end

        context "of member user" do
          before { user.alchemy_roles = %w(member) }

          it "delivers the welcome mail." do
            Notifications.should_receive(:member_created).and_return(OpenStruct.new(deliver: true))
            user.save!
          end
        end
      end

      context "with send_credentials set to false" do
        before { user.send_credentials = false }

        it "does not deliver any mail" do
          Notifications.should_not_receive(:alchemy_user_created)
          user.save!
        end
      end
    end

    describe 'scopes' do
      let(:user) { create(:alchemy_admin_user) }

      describe '.admins' do
        it "should only return users with admin role" do
          User.admins.should include(user)
        end
      end
    end

    describe ".human_rolename" do
      it "return a translated role name" do
        ::I18n.locale = :de
        User.human_rolename('member').should == "Mitglied"
      end
    end

    describe "#human_roles_string" do
      it "should return a humanized roles string." do
        ::I18n.locale = :de
        user.alchemy_roles = ['member', 'admin']
        user.human_roles_string.should == "Mitglied und Administrator"
      end
    end

    describe '#role_symbols' do
      it "should return an array of user role symbols" do
        user.role_symbols.should == [:member]
      end
    end

    describe '#has_role?' do
      context "with given role" do
        it "should return true." do
          user.has_role?('member').should be_true
        end
      end

      context "with role given as symbol" do
        it "should return true." do
          user.has_role?(:member).should be_true
        end
      end

      context "without given role" do
        it "should return true." do
          user.has_role?('admin').should be_false
        end
      end
    end

    describe '#role' do
      context "when user doesn't have any roles" do
        before { user.alchemy_roles = [] }

        it 'should return nil' do
          user.role.should be_nil
        end
      end

      context "when user has multiple roles" do
        before { user.alchemy_roles = ["admin", "member"] }

        it 'should return the first role' do
          user.role.should == "admin"
        end
      end
    end

    describe '#alchemy_roles' do
      it "should return an array of user roles" do
        user.alchemy_roles.should == ["member"]
      end
    end

    describe '#alchemy_roles=' do

      it "should accept an array of user roles" do
        user.alchemy_roles = ["admin"]
        user.alchemy_roles.should == ["admin"]
      end

      it "should accept a string of user roles" do
        user.alchemy_roles = "admin member"
        user.alchemy_roles.should == ["admin", "member"]
      end

      it "should store the user roles as space seperated string" do
        user.alchemy_roles = ["admin", "member"]
        user.read_attribute(:alchemy_roles).should == "admin member"
      end

    end

    describe "#add_role" do
      it "should add the given role to roles array" do
        user.add_role "admin"
        user.alchemy_roles.should == ["member", "admin"]
      end

      it "should not add the given role twice" do
        user.add_role "member"
        user.alchemy_roles.should == ["member"]
      end
    end

    describe '#logged_in?' do
      before { Config.stub(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 30.minutes.ago
        user.save!
        user.logged_in?.should be_true
      end
    end

    describe '#logged_out?' do
      before { Config.stub(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 2.hours.ago
        user.save!
        user.logged_out?.should be_true
      end
    end

    describe "#pages_locked_by_me" do
      let(:user) { create(:alchemy_admin_user) }
      let(:page) { create(:page) }

      before { Alchemy::PageLayout.stub(:get).and_return({}) }

      it "should return all pages that are locked by user" do
        user.save!
        page.lock_to!(user)
        user.locked_pages.should include(page)
      end
    end

    describe '#unlock_pages' do
      before do
        user.save!
        page.lock_to!(user)
      end

      it "should unlock all users lockes pages" do
        user.unlock_pages!
        user.locked_pages.should be_empty
      end
    end

    describe '#is_admin?' do
      it "should return true if the user has admin role" do
        user.alchemy_roles = "admin"
        user.is_admin?.should be_true
      end
    end

    describe '#fullname' do
      it "should return the firstname and lastname" do
        user.fullname.should == "John Doe"
      end

      context "user without firstname and lastname" do
        it "should return the login" do
          user.firstname = nil
          user.lastname = nil
          user.fullname.should == user.login
        end
      end

      context "with flipped option set to true" do
        it "should return the lastname and firstname comma seperated" do
          user.fullname(flipped: true).should == "Doe, John"
        end
      end

      context "with blank firstname" do
        it "should not have whitespace" do
          user.firstname = nil
          user.fullname.should == "Doe"
        end
      end
    end

    describe '#store_request_time!' do
      let(:user) { create(:alchemy_admin_user) }

      it "should store the timestamp of the request" do
        last_request_at = 2.hours.ago
        user.last_request_at = last_request_at
        user.save!
        user.store_request_time!
        user.last_request_at.should_not == last_request_at
      end
    end

  end
end
