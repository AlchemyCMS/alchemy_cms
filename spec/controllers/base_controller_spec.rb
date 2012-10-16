require 'spec_helper'

module Alchemy
  describe BaseController do

    let(:default_language) { Language.get_default }
    let(:klingonian) { FactoryGirl.create(:klingonian) }

    describe "#set_language_from" do

      it "should set the language from id" do
        controller.send :set_language_from, default_language.id
        controller.session[:language_id].should == default_language.id
      end

      it "should set the language from code" do
        controller.send :set_language_from, klingonian.code
        controller.session[:language_id].should == klingonian.id
        controller.session[:language_code].should == klingonian.code
      end

      it "should set the language from id as string" do
        controller.send :set_language_from, default_language.id.to_s
        controller.session[:language_id].should == default_language.id
        controller.session[:language_code].should == default_language.code
      end

    end

    describe "#set_language" do

      context "with no lang param" do

        it "should set the default language" do
          controller.stub!(:params).and_return({})
          controller.send :set_language
          controller.session[:language_id].should == default_language.id
          controller.session[:language_code].should == default_language.code
        end

      end

      context "with lang param" do

        it "should set the language" do
          controller.stub!(:params).and_return({:lang => klingonian.code})
          controller.send :set_language
          controller.session[:language_id].should == klingonian.id
          controller.session[:language_code].should == klingonian.code
        end

        context "for language that does not exist" do

          before do
            controller.stub!(:params).and_return({:lang => 'fo'})
            controller.send :set_language
          end

          it "should set the language to default" do
            controller.session[:language_id].should == default_language.id
            controller.session[:language_code].should == default_language.code
          end

          it "should set the rails locale to default language code" do
            ::I18n.locale.should == default_language.code.to_sym
          end

          it "should not set the rails locale to requested locale" do
            ::I18n.locale.should_not == :fo
          end

        end

      end

    end

  end
end
