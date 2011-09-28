require 'spec_helper'

describe User do
  
  it "should have a role" do
    @user = Factory.create(:user)
    @user.role.should_not be_nil
  end
  
end
