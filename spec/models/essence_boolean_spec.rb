require 'spec_helper'

module Alchemy
  describe EssenceBoolean do

    it "should act as essence" do
      expect { EssenceBoolean.new.acts_as_essence? }.to_not raise_error(NoMethodError)
    end

    it "should have correct partial path" do
      EssenceBoolean.new.to_partial_path.should == 'alchemy/essences/essence_boolean_view'
    end

  end
end
