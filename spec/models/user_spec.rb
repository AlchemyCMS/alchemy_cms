require 'spec_helper'

module Alchemy
  describe User do

    let(:user) { FactoryGirl.build(:user) }
    let(:page) { FactoryGirl.create(:page) }

    it "should have at least registered role" do
      user.save!
      user.roles.should_not be_blank
      user.roles.should include('registered')
    end

    describe 'scopes' do
      describe '.admins' do
        before do
          user.roles = 'admin'
          user.save!
        end

        it "should only return users with admin role" do
          User.admins.should include(user)
        end
      end
    end

    describe ".human_rolename" do
      it "return a translated role name" do
        ::I18n.locale = :de
        User.human_rolename('registered').should == "Registriert"
      end
    end

    describe "#human_roles_string" do
      it "should return a humanized roles string." do
        ::I18n.locale = :de
        user.roles = ['registered', 'admin']
        user.human_roles_string.should == "Registriert und Administrator"
      end
    end

    describe '#role_symbols' do
      it "should return an array of user role symbols" do
        user.role_symbols.should == [:registered]
      end
    end

    describe '#has_role?' do

      context "with given role" do
        it "should return true." do
          user.has_role?('registered').should be_true
        end
      end

      context "with role given as symbol" do
        it "should return true." do
          user.has_role?(:registered).should be_true
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
        before { user.roles = [] }

        it 'should return nil' do
          user.role.should be_nil
        end
      end

      context "when user has multiple roles" do
        before { user.roles = ["admin", "registered"] }

        it 'should return the first role' do
          user.role.should == "admin"
        end
      end
    end

    describe '#roles' do
      it "should return an array of user roles" do
        user.roles.should == ["registered"]
      end
    end

    describe '#roles=' do

      it "should accept an array of user roles" do
        user.roles = ["admin"]
        user.roles.should == ["admin"]
      end

      it "should accept a string of user roles" do
        user.roles = "admin registered"
        user.roles.should == ["admin", "registered"]
      end

      it "should store the user roles as space seperated string" do
        user.roles = ["admin", "registered"]
        user.read_attribute(:roles).should == "admin registered"
      end

    end

    describe "#add_role" do
      it "should add the given role to roles array" do
        user.add_role "member"
        user.roles.should == ["registered", "member"]
      end

      it "should not add the given role twice" do
        user.add_role "registered"
        user.roles.should == ["registered"]
      end
    end

    describe '#logged_in?' do
      before { Config.stub!(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 30.minutes.ago
        user.save!
        user.logged_in?.should be_true
      end
    end

    describe '#logged_out?' do
      before { Config.stub!(:get).and_return 60 }

      it "should return logged in status" do
        user.last_request_at = 2.hours.ago
        user.save!
        user.logged_out?.should be_true
      end
    end

    describe "#pages_locked_by_me" do
      it "should return all pages that are locked by user" do
        user.save!
        page.lock(user)
        user.locked_pages.should include(page)
      end
    end

    describe '#unlock_pages' do
      before do
        user.save!
        page.lock(user)
      end

      it "should unlock all users lockes pages" do
        user.unlock_pages!
        user.locked_pages.should be_empty
      end
    end

    describe '#is_admin?' do
      it "should return true if the user has admin role" do
        user.roles = "admin"
        user.save!
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
          user.fullname.should == "jdoe"
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
