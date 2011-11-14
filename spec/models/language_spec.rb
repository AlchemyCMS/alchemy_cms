# encoding: UTF-8
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
	
	describe "before save" do
		describe "#remove_old_default if default attribute has changed to true" do
		  it "should unset the default status of the old default-language" do
				@default_language = Language.get_default
				@language.update_attributes(:default => true)
				@default_language.reload
				@default_language.default.should be(false)
			end
		end
	end
	
	describe "after validation on update" do
		describe "#set_pages_language if language´s code has changed" do
			it "should update all its pages with the new code" do
				@page = Factory(:page, :language => @language)
				@other_page = Factory(:page, :language => @language)
				@language.update_attributes(:code => "fo")
				@language.reload; @page.reload; @other_page.reload
				[@page.language_code, @other_page.language_code].should == [@language.code, @language.code]
		  end
		end
	end

end
