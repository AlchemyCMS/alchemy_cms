# frozen_string_literal: true

require 'spec_helper'

describe 'Alchemy::AuthAccessors' do
  describe '.user_class' do
    it "injects userstamp class methods" do
      expect(Alchemy.user_class).to respond_to(:stamper_class_name)
      expect(Alchemy.user_class.stamper_class_name).to eq(:DummyUser)
    end
  end
end
