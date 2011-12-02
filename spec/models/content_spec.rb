require 'spec_helper'

describe Alchemy::Content do

  it "should return the ingredient from its essence" do
    Factory(:element)
		Alchemy::EssenceText.first.update_attributes(:body => "Hello")
		Alchemy::Content.first.ingredient.should == Alchemy::EssenceText.first.ingredient
  end

	describe '.normalize_essence_type' do

		context "passing namespaced essence type" do

			it "should not add alchemy namespace" do
				Alchemy::Content.normalize_essence_type('Alchemy::EssenceText').should == "Alchemy::EssenceText"
			end

		end

		context "passing not namespaced essence type" do

			it "should add alchemy namespace" do
				Alchemy::Content.normalize_essence_type('EssenceText').should == "Alchemy::EssenceText"
			end

		end

	end

	describe '#normalized_essence_type' do

		context "without namespace in essence_type column" do

			it "should return the namespaced essence type" do
				Alchemy::Content.new(:essence_type => 'EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
			end

		end

		context "with namespace in essence_type column" do

			it "should return the namespaced essence type" do
				Alchemy::Content.new(:essence_type => 'Alchemy::EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
			end

		end

	end

end
