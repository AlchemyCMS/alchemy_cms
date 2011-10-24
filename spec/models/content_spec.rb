require 'spec_helper'

describe Content do

  it "should return the ingredient from its essence" do
    Factory(:element)
		EssenceText.first.update_attributes(:body => "Hello")
		Content.first.ingredient.should == EssenceText.first.ingredient
  end

end
