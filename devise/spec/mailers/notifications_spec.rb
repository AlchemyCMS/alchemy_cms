require 'spec_helper'

module Alchemy
  describe Notifications do

    context "when a member user was created" do
      let(:user) { mock_model('User', alchemy_roles: %w(member), email: 'jon@doe.com', name: 'John Doe', login: 'jon.doe') }
      let(:mail) { Notifications.member_created(user) }

      it "delivers a mail to user" do
        mail.to.should == [user.email]
        mail.subject.should == 'Your user credentials'
      end

      it "mail body includes users name" do
        mail.body.should match /#{user.name}/
      end

      it "mail body includes users login" do
        mail.body.should match /#{user.login}/
      end

      it "mail body includes password instructions" do
        mail.body.should match /#{Regexp.escape(new_password_url(email: user.email, use_route: 'alchemy', only_path: true))}/
      end
    end

    context "when an admin user was created" do
      let(:user) { mock_model('User', alchemy_roles: %w(admin), email: 'jon@doe.com', name: 'John Doe', login: 'jon.doe') }
      let(:mail) { Notifications.alchemy_user_created(user) }

      it "delivers a mail to user" do
        mail.to.should == [user.email]
        mail.subject.should == 'Your Alchemy Login'
      end

      it "mail body includes users login" do
        mail.body.should match /#{user.login}/
      end

      it "mail body includes password instructions" do
        mail.body.should match /#{Regexp.escape(new_password_url(use_route: 'alchemy', only_path: true))}/
      end
    end

    describe '#reset_password_instructions' do
      let(:user) { mock_model('User', alchemy_roles: %w(member), email: 'jon@doe.com', name: 'John Doe', login: 'jon.doe') }
      let(:mail) { Notifications.reset_password_instructions(user) }

      before { user.stub(:reset_password_token).and_return('123') }

      it "delivers a mail to user" do
        mail.to.should == [user.email]
        mail.subject.should == 'Reset password instructions'
      end

      it "mail body includes users name" do
        mail.body.should match /#{user.name}/
      end

      it "mail body includes reset instructions" do
        mail.body.should match /#{Regexp.escape(edit_password_url(user, reset_password_token: user.reset_password_token, use_route: 'alchemy', only_path: true))}/
      end
    end

  end
end
