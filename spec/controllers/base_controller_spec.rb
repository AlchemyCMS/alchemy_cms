require 'spec_helper'

# Here's a tiny custom matcher making it a bit easier to check the
# current session for a language configuration.
#
RSpec::Matchers.define :include_language_information_for do |expected|
  match do |actual|
    actual[:alchemy_language_id] == expected.id
  end
end

module Alchemy
  describe BaseController do

    let(:default_language) { Language.default }
    let(:klingonian) { FactoryGirl.create(:klingonian) }

    describe "#set_alchemy_language" do

      context "with a Language argument" do
        it "should set the language to the passed Language instance" do
          controller.send :set_alchemy_language, klingonian
          assigns(:language).should == klingonian
        end
      end

      context "with a language id argument" do
        it "should set the language to the language specified by the passed id" do
          controller.send :set_alchemy_language, klingonian.id
          assigns(:language).should == klingonian
        end
      end

      context "with a language code argument" do
        it "should set the language to the language specified by the passed code" do
          controller.send :set_alchemy_language, klingonian.code
          assigns(:language).should == klingonian
        end
      end

      context "with no lang param" do

        it "should set the default language" do
          controller.stub(:params).and_return({})
          controller.send :set_alchemy_language
          assigns(:language).should == default_language
          controller.session.should include_language_information_for(default_language)
        end
      end

      context "with language in the session" do
        before do
          controller.stub(:session).and_return(alchemy_language_id: klingonian.id)
          Language.stub(current: klingonian)
        end

        it "should use the language from the session" do
          controller.send :set_alchemy_language
          assigns(:language).should == klingonian
        end
      end

      context "with lang param" do

        it "should set the language" do
          controller.stub(:params).and_return(lang: klingonian.code)
          controller.send :set_alchemy_language
          assigns(:language).should == klingonian
          controller.session.should include_language_information_for(klingonian)
        end

        context "for language that does not exist" do

          before do
            controller.stub(:params).and_return(lang: 'fo')
            controller.send :set_alchemy_language
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

    describe "#current_alchemy_user" do

      context "with default current_user_method" do

        it "calls current_user by default" do
          controller.should_receive :current_user
          controller.send :current_alchemy_user
        end
      end

      context "with custom current_user_method" do

        before do
          Alchemy.current_user_method = 'current_admin'
        end

        it "calls the custom method" do
          controller.should_receive :current_admin
          controller.send :current_alchemy_user
        end
      end

      context "with not implemented current_user_method" do

        before do
          Alchemy.current_user_method = 'not_implemented_method'
        end

        after do
          Alchemy.current_user_method = 'current_user'
        end

        it "raises an error" do
          expect{
            controller.send :current_alchemy_user
          }.to raise_error(NoCurrentUserFoundError)
        end
      end
    end

  end
end
