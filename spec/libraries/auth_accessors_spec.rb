require 'spec_helper'

module Alchemy
  class MyCustomUser
  end

  describe 'AuthAccessors' do
    describe '.user_class' do
      before {
        # prevent memoization
        Alchemy.class_variable_set('@@user_class', nil)
      }

      it "raises error if user_class_name is not a String" do
        Alchemy.user_class_name = MyCustomUser
        expect {Alchemy.user_class }.to raise_error
      end

      after {
        Alchemy.user_class_name = 'DummyUser'
      }
    end
  end
end
