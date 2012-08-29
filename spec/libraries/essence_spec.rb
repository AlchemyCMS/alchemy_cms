require 'spec_helper'

describe "ActsAsEssence" do

  let(:element) { FactoryGirl.create(:element, :name => 'headline', :create_contents_after_create => true) }

  describe '#ingredient=' do

    it "should set the value to ingredient column" do
      content = element.content_by_name('headline')
      content.essence.ingredient = 'Hallo'
      content.essence.save
      content.essence.ingredient.should == 'Hallo'
    end

  end

end
