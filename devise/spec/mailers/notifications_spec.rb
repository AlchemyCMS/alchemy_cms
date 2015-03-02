require 'spec_helper'

module Alchemy
  describe Notifications do

    context "when a member user was created" do
      let(:user) do
        mock_model 'User',
          alchemy_roles: %w(member),
          email: 'jon@doe.com',
          name: 'John Doe',
          login: 'jon.doe'
      end
      let(:mail) { Notifications.member_created(user) }

      it "delivers a mail to user" do
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq('Your user credentials')
      end

      it "mail body includes users name" do
        expect(mail.body.raw_source).to have_content user.name
      end

      it "mail body includes users login" do
        expect(mail.body.raw_source).to have_content user.login
      end

      it "mail body includes password instructions" do
        expect(mail.body.raw_source).to match /#{Regexp.escape(new_password_url(email: user.email, only_path: true))}/
      end
    end

    context "when an admin user was created" do
      let(:user) { mock_model('User', alchemy_roles: %w(admin), email: 'jon@doe.com', name: 'John Doe', login: 'jon.doe') }
      let(:mail) { Notifications.alchemy_user_created(user) }

      it "delivers a mail to user" do
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq('Your Alchemy Login')
      end

      it "mail body includes users login" do
        expect(mail.body.raw_source).to match /#{user.login}/
      end

      it "mail body includes password instructions" do
        expect(mail.body.raw_source).to match /#{Regexp.escape(new_password_url(only_path: true))}/
      end
    end

    describe '#reset_password_instructions' do
      let(:user) do
        mock_model 'User',
          alchemy_roles: %w(member),
          email: 'jon@doe.com',
          name: 'John Doe',
          login: 'jon.doe',
          fullname: 'John Doe'
      end

      let(:token) { '123456789' }

      let(:mail) do
        Notifications.reset_password_instructions(user, token)
      end

      it "delivers a mail to user" do
        expect(mail.to).to eq([user.email])
        expect(mail.subject).to eq('Reset password instructions')
      end

      it "mail body includes users name" do
        expect(mail.body.raw_source).to match /#{user.name}/
      end

      it "mail body includes reset instructions" do
        expect(mail.body.raw_source).to match /#{Regexp.escape(edit_password_url(user, reset_password_token: token, only_path: true))}/
      end
    end
  end
end
