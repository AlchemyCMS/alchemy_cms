require 'spec_helper'

describe Alchemy::EssenceSelect do

  it "should act as essence" do
    expect { Alchemy::EssenceSelect.new.acts_as_essence? }.should_not raise_error(NoMethodError)
  end

  it "should have correct partial path" do
    Alchemy::EssenceSelect.new.to_partial_path.should == 'alchemy/essences/essence_select_view'
  end

end
