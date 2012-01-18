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

	describe '#update_essence' do

		it "should update the attributes of related essence and return true" do
			@element = Factory(:element, :name => 'text')
			@content = @element.contents.first
			@content.update_essence(:body => 'Mikes Petshop')
			@content.ingredient.should == "Mikes Petshop"
		end

		it "should add error messages if save fails and return false" do
			@element = Factory(:element, :name => 'contactform')
			@content = @element.contents.first
			@content.update_essence
			@content.errors[:essence].should have(1).item
		end

		it "should raise error if essence is missing" do
			@element = Factory(:element, :name => 'text')
			@content = @element.contents.first
			@content.update_essence
		end

	end

	describe '#copy' do

		before(:each) do
			@element = Factory(:element, :name => 'text')
			@content = @element.contents.first
		end

		it "should create a new record with all attributes of source except given differences" do
			copy = Alchemy::Content.copy(@content, {:name => 'foobar', :element_id => @element.id + 1})
			copy.name.should == 'foobar'
		end

		it "should make a new record for essence of source" do
			copy = Alchemy::Content.copy(@content, {:element_id => @element.id + 1})
			copy.essence_id.should_not == @content.essence_id
		end

		it "should copy source essence attributes" do
			copy = Alchemy::Content.copy(@content, {:element_id => @element.id + 1})
			copy.essence.body == @content.essence.body
		end

	end

end
