require 'spec_helper'

describe Element do

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
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', 'config', 'alchemy', 'elements.yml'), File.join(File.dirname(__FILE__), '..', 'config', 'alchemy', 'elements.yml.bak'))
		expect { Element.descriptions }.should raise_error
		FileUtils.mv(File.join(File.dirname(__FILE__), '..', 'config', 'alchemy', 'elements.yml.bak'), File.join(File.dirname(__FILE__), '..', 'config', 'alchemy', 'elements.yml'))
	end

end
