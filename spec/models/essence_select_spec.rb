require 'spec_helper'

module Alchemy
  describe EssenceSelect do

    it "should act as essence" do
      expect { EssenceSelect.new.acts_as_essence? }.to_not raise_error
    end

    it "should have correct partial path" do
      EssenceSelect.new.to_partial_path.should == 'alchemy/essences/essence_select_view'
    end

  end
end
