require 'spec_helper'

describe Element do

  it "should return a list of element definitions for a list of element names" do
		pending "because YAML is different in test environment. Great Rails!!!!"
		element_names = ["article"]
		definitions = Element.all_definitions_for(element_names)
		definitions.should == [{:name => 'article'}]
  end

  it "should always return an array calling all_definitions_for()" do
		definitions = Element.all_definitions_for(nil)
		definitions.should == []
  end

end
