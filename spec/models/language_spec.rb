# encoding: UTF-8
require 'spec_helper'

describe Alchemy::Language do

	before(:each) do
		@language = Factory(:language)
	end

	it "should return a label for code" do
	  @language.label(:code).should == 'kl'
	end

	it "should return a label for name" do
		@language.label(:name).should == 'Klingonian'
	end

	context "with country_code and_language_code" do

	  	it "should return a joined locale" do
	  		@language.country_code = 'cr'
			@language.code.should == 'kl-cr'
		end

	end

	context "with language_code and country code as emtpy string" do
	  
	  	it "should return language locale only" do
	  		@language.country_code = ''
			@language.code.should == 'kl'
		end

	end

	it "should not be deletable if it is the default language" do
		@default_language = Alchemy::Language.find_by_default(true)
		if !@default_language
			@default_language = Factory(:language, :name => "default", :code => "aa", :frontpage_name => "intro", :default => true)
		end
		expect { @default_language.destroy }.should raise_error
	end

	describe "before save" do
		describe "#remove_old_default if default attribute has changed to true" do
		  it "should unset the default status of the old default-language" do
				@default_language = Alchemy::Language.get_default
				@language.update_attributes(:default => true)
				@default_language.reload
				@default_language.default.should be(false)
			end
		end
	end

	context "after_update" do
		describe "#set_pages_language if language´s code has changed" do
			it "should update all its pages with the new code" do
				@page = Factory(:page, :language => @language)
				@other_page = Factory(:page, :language => @language)
				@language.update_attributes(:code => "fo")
				@language.reload; @page.reload; @other_page.reload
				[@page.language_code, @other_page.language_code].should == [@language.code, @language.code]
		  end
		end
		describe "#unpublish_pages" do
			it "should set all pages to unpublic if it gets set to unpublic" do
				@page = Factory(:page, :language => @language)
				@other_page = Factory(:page, :language => @language)
				@language.update_attributes(:public => false)
				@language.reload; @page.reload; @other_page.reload
				[@page.public?, @other_page.public?].should == [false, false]
			end
		end
	end

end
