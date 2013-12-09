require 'spec_helper'

describe 'Alchemy::AuthAccessors' do
  describe '.user_class' do
    it "injects userstamp class methods" do
      Alchemy.user_class.should respond_to(:stamper_class_name)
      Alchemy.user_class.stamper_class_name.should eq(:DummyUser)
    end
  end
end
