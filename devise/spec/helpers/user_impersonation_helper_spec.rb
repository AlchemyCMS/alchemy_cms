# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Devise::UserImpersonationHelper, type: :helper do
  let(:user) { build_stubbed(:alchemy_member_user, firstname: "Target", lastname: "User") }

  before do
    allow(helper).to receive(:current_alchemy_user).and_return(user)
  end

  it "renders an identifying notice and DELETE stop action while impersonating" do
    session[:alchemy_devise_original_user_id] = 123

    notice = helper.alchemy_user_impersonation_notice

    expect(notice).to include("You are impersonating Target User")
    expect(notice).to include("Stop impersonating")
    expect(notice).to include('name="_method" value="delete"')
  end

  it "renders nothing during an ordinary session" do
    expect(helper.alchemy_user_impersonation_notice).to be_nil
  end
end
