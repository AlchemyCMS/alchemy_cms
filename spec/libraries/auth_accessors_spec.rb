# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  class MyCustomUser
  end

  describe 'AuthAccessors' do
    describe '.user_class' do
      before do
        # prevent memoization
        Alchemy.class_variable_set('@@user_class', nil)
      end

      it "raises error if user_class_name is not a String" do
        Alchemy.user_class_name = MyCustomUser
        expect {
          Alchemy.user_class
        }.to raise_error(TypeError)
      end

      after do
        Alchemy.user_class_name = 'DummyUser'
      end
    end

    describe 'defaults' do
      it 'has default value for Alchemy.signup_path' do
        expect(Alchemy.signup_path).to eq('/signup')
      end

      it 'has default value for Alchemy.login_path' do
        expect(Alchemy.login_path).to eq('/login')
      end

      it 'has default value for Alchemy.logout_path' do
        expect(Alchemy.logout_path).to eq('/logout')
      end
    end
  end
end
