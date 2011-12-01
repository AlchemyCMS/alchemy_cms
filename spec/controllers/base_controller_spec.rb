require 'spec_helper'

describe Alchemy::BaseController do

	describe "#set_language_from" do

		it "should set the language from id" do
			@language = Alchemy::Language.get_default
			controller.send :set_language_from, @language.id
			controller.session[:language_id].should == @language.id
		end

		it "should set the language from code" do
			@language = Factory(:language, :code => 'kl')
			controller.send :set_language_from, "kl"
			controller.session[:language_id].should == @language.id
			controller.session[:language_code].should == @language.code
		end

		it "should set the language from id as string", :focus => true do
			@language = Factory(:language)
			controller.send :set_language_from, @language.id.to_s
			controller.session[:language_id].should == @language.id
			controller.session[:language_code].should == @language.code
		end

	end

	describe "#set_language" do

		context "with no lang param" do

			it "should set the default language" do
				controller.stub!(:params).and_return({})
				controller.send :set_language
				controller.session[:language_id].should == Alchemy::Language.get_default.id
				controller.session[:language_code].should == Alchemy::Language.get_default.code
			end

		end

		context "with lang param" do

			it "should set the language" do
				@language = Factory(:language)
				controller.stub!(:params).and_return({:lang => 'kl'})
				controller.send :set_language
				controller.session[:language_id].should == @language.id
				controller.session[:language_code].should == @language.code
			end

			context "for language that does not exist" do

				it "should set the language to default" do
					controller.stub!(:params).and_return({:lang => 'fo'})
					controller.send :set_language
					controller.session[:language_id].should == Alchemy::Language.get_default.id
					controller.session[:language_code].should == Alchemy::Language.get_default.code
				end

			end

		end

	end

end
