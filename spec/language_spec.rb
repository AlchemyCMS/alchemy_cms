require 'spec_helper'

describe Language do

	before(:all) do
		@language = Factory(:language)
	end
	
	after(:all) do
		@language.destroy if @language
	end

	it "should return a label for code" do
	  @language.label(:code).should == 'kl'
	end 

	it "should return a label for name" do
		@language.label(:name).should == 'Klingonian'
	end
		
	it "should not be deletable if it is the default language" do
		@default_language = Language.find_by_default(true)
		if !@default_language
			@default_language = Factory(:language, :name => "default", :code => "aa", :frontpage_name => "intro", :default => true)
		end
		expect { @default_language.destroy }.should raise_error
	end

end
