require 'spec_helper'

describe Element do

	context "scoped" do

	  before(:each) do
			Element.delete_all
	  end

		it "should return all public elements" do
			elements = [Factory(:element, :public => true), Factory(:element, :public => true)]
		  Element.published.all.should == elements
		end

		it "should return all elements by name" do
			elements = [Factory(:element, :name => 'article'), Factory(:element, :name => 'article')]
		  Element.named(['article']).all.should == elements
		end

		it "should return all elements but excluded ones" do
			Factory(:element, :name => 'article')
			Factory(:element, :name => 'article')
			excluded = [Factory(:element, :name => 'claim')]
		  Element.excluded(['article']).all.should == excluded
		end

	end

  it "should return a list of element definitions for a list of element names" do
		element_names = ["article"]
		definitions = Element.all_definitions_for(element_names)
		definitions.first.fetch("name").should == 'article'
  end

  it "should always return an array calling all_definitions_for()" do
		definitions = Element.all_definitions_for(nil)
		definitions.should == []
  end

	it "should raise an error if no descriptions are found" do
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'))
		expect { Element.descriptions }.should raise_error
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml.bak'), File.join(File.dirname(__FILE__), '..', '..', 'config', 'alchemy', 'elements.yml'))
	end

	it "should return an ingredient by name" do
		element = Factory(:element)
		element.ingredient('intro').should == EssenceText.first.ingredient
	end

end
