require 'spec_helper'

# Here's a tiny custom matcher making it a bit easier to check the
# current session for a language configuration.
#
RSpec::Matchers.define :include_language_information_for do |expected|
  match do |actual|
    actual[:language_id] == expected.id && actual[:language_code] == expected.code
  end
end

module Alchemy
  describe BaseController do

    let(:default_language) { Language.get_default }
    let(:klingonian) { FactoryGirl.create(:klingonian) }

    describe "#set_language" do

      context "with a Language argument" do
        it "should set the language to the passed Language instance" do
          controller.send :set_language, klingonian
          assigns(:language).should == klingonian
        end
      end

      context "with a language id argument" do
        it "should set the language to the language specified by the passed id" do
          controller.send :set_language, klingonian.id
          assigns(:language).should == klingonian
        end
      end

      context "with a language code argument" do
        it "should set the language to the language specified by the passed code" do
          controller.send :set_language, klingonian.code
          assigns(:language).should == klingonian
        end
      end

      context "with no lang param" do

        it "should set the default language" do
          controller.stub!(:params).and_return({})
          controller.send :set_language
          assigns(:language).should == default_language
          controller.session.should include_language_information_for(default_language)
        end

      end

      context "with language set in the session" do
        before do
          controller.stub!(:session).and_return(language_id: klingonian.id, language_code: klingonian.code)
        end

        it "should use the language set in the session cookie" do
          controller.send :set_language
          assigns(:language).should == klingonian
        end
      end

      context "with lang param" do

        it "should set the language" do
          controller.stub!(:params).and_return(:lang => klingonian.code)
          controller.send :set_language
          assigns(:language).should == klingonian
          controller.session.should include_language_information_for(klingonian)
        end

        context "for language that does not exist" do

          before do
            controller.stub!(:params).and_return(:lang => 'fo')
            controller.send :set_language
          end

          it "should set the language to default" do
            assigns(:language).should == default_language
            controller.session.should include_language_information_for(default_language)
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

    describe '#store_user_request_time' do

      context "user not logged in" do
        before { controller.stub!(:user_signed_in?).and_return(false) }

        it "should not store the current request time" do
          controller.send(:store_user_request_time).should == nil
        end

      end

      context "user logged in" do
        before do
          controller.stub!(:user_signed_in?).and_return(true)
          controller.stub!(:current_user).and_return(FactoryGirl.create(:user))
        end

        it "should not store the current request time" do
          controller.send(:store_user_request_time).should == true
        end

      end

    end
    
    describe "#layout_for_page" do
      it "should return false if params[:layout] is set to false" do
        controller.stub!(:params).and_return(layout: 'false')
        expect(controller.send(:layout_for_page)).to be_false
      end

      it "should return false if params[:layout] is set to none" do
        controller.stub!(:params).and_return(layout: 'none')
        expect(controller.send(:layout_for_page)).to be_false
      end

      it "should return the layout name set through params[:layout]" do
        controller.stub!(:params).and_return(layout: 'my_layout')
        expect(controller.send(:layout_for_page)).to eq('my_layout')
      end

      it "should return 'application' if params[:layout] is not set" do
        controller.stub!(:params).and_return({})
        expect(controller.send(:layout_for_page)).to eq('application')
      end
    end

  end
end
