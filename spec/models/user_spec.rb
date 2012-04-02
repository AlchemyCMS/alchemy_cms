require 'spec_helper'

describe Alchemy::User do

  it "should have a role" do
    @user = Factory.build(:user)
    @user.save_without_session_maintenance
    @user.role.should_not be_nil
  end

end
