require 'spec_helper'

module Alchemy
  describe User do

    let(:user) { FactoryGirl.build(:user) }
    let(:page) { FactoryGirl.create(:page) }

    it "should have a role" do
      user.save!
      user.role.should_not be_nil
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
        user.role = "admin"
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
