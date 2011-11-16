require 'spec_helper'

describe Alchemy::Content do

  it "should return the ingredient from its essence" do
    Factory(:element)
		Alchemy::EssenceText.first.update_attributes(:body => "Hello")
		Alchemy::Content.first.ingredient.should == Alchemy::EssenceText.first.ingredient
  end

end
