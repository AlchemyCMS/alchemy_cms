require "spec_helper"

describe Alchemy::PasswordsController do
  let(:user) { mock_model('User', alchemy_roles: %w(admin), email: 'admin@alchemy.com') }

  describe '#post' do
    it "should send email with reset password instructions" do
      ActionMailer::Base.deliveries = []
      @request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, user: {email: user.email}
      ActionMailer::Base.deliveries.should_not be_empty
    end
  end
end
