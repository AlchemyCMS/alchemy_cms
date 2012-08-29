require 'spec_helper'

module Alchemy
  describe Content do

    let(:element) { FactoryGirl.create(:element, :name => 'headline', :create_contents_after_create => true) }
    let(:content) { element.contents.find_by_essence_type('Alchemy::EssenceText') }

    it "should return the ingredient from its essence" do
      content.essence.update_attributes(:body => "Hello")
      content.ingredient.should == "Hello"
    end

    describe '.normalize_essence_type' do

      context "passing namespaced essence type" do

        it "should not add alchemy namespace" do
          Content.normalize_essence_type('Alchemy::EssenceText').should == "Alchemy::EssenceText"
        end

      end

      context "passing not namespaced essence type" do

        it "should add alchemy namespace" do
          Content.normalize_essence_type('EssenceText').should == "Alchemy::EssenceText"
        end

      end

    end

    describe '#normalized_essence_type' do

      context "without namespace in essence_type column" do

        it "should return the namespaced essence type" do
          Content.new(:essence_type => 'EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
        end

      end

      context "with namespace in essence_type column" do

        it "should return the namespaced essence type" do
          Content.new(:essence_type => 'Alchemy::EssenceText').normalized_essence_type.should == 'Alchemy::EssenceText'
        end

      end

    end

    describe '#update_essence' do

      it "should update the attributes of related essence and return true" do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence(:body => 'Mikes Petshop')
        @content.ingredient.should == "Mikes Petshop"
      end

      it "should add error messages if save fails and return false" do
        @element = FactoryGirl.create(:element, :name => 'contactform', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence
        @content.errors[:essence].should have(1).item
      end

      it "should raise error if essence is missing" do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
        @content.update_essence
      end

    end

    describe '#copy' do

      before(:each) do
        @element = FactoryGirl.create(:element, :name => 'text', :create_contents_after_create => true)
        @content = @element.contents.first
      end

      it "should create a new record with all attributes of source except given differences" do
        copy = Content.copy(@content, {:name => 'foobar', :element_id => @element.id + 1})
        copy.name.should == 'foobar'
      end

      it "should make a new record for essence of source" do
        copy = Content.copy(@content, {:element_id => @element.id + 1})
        copy.essence_id.should_not == @content.essence_id
      end

      it "should copy source essence attributes" do
        copy = Content.copy(@content, {:element_id => @element.id + 1})
        copy.essence.body == @content.essence.body
      end

    end

  end
end
