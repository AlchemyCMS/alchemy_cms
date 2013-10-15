require "spec_helper"

module Alchemy
  describe PasswordsController do
    let(:user) { FactoryGirl.create(:admin_user) }

    describe '#post' do
      it "should send email with reset password instructions" do
        ActionMailer::Base.deliveries = []
        @request.env["devise.mapping"] = Devise.mappings[:user]
        post :create, :user => {:email => user.email}
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end
  end
end
