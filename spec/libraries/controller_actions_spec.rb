require 'spec_helper'

# Here's a tiny custom matcher making it a bit easier to check the
# current session for a language configuration.
#
RSpec::Matchers.define :include_language_information_for do |expected|
  match do |actual|
    actual[:alchemy_language_id] == expected.id
  end
end

describe 'Alchemy::ControllerActions', type: 'controller' do
  # Anonymous controller to test the integration against
  controller(ActionController::Base) do
    include Alchemy::ControllerActions
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
        }.to raise_error(Alchemy::NoCurrentUserFoundError)
      end
    end
  end

  describe "#set_alchemy_language" do
    let(:default_language) { Alchemy::Language.default }
    let(:klingonian)       { FactoryGirl.create(:klingonian) }

    after do
      # We must never change the app's locale
      expect(::I18n.locale).to eq(:en)
    end

    context "with a Language argument" do
      it "should set the language to the passed Language instance" do
        controller.send :set_alchemy_language, klingonian
        assigns(:language).should == klingonian
        expect(Alchemy::Language.current).to eq(klingonian)
      end
    end

    context "with a language id argument" do
      it "should set the language to the language specified by the passed id" do
        controller.send :set_alchemy_language, klingonian.id
        assigns(:language).should == klingonian
        expect(Alchemy::Language.current).to eq(klingonian)
      end
    end

    context "with a language code argument" do
      it "should set the language to the language specified by the passed code" do
        controller.send :set_alchemy_language, klingonian.code
        assigns(:language).should == klingonian
        expect(Alchemy::Language.current).to eq(klingonian)
      end
    end

    context "with no lang param" do
      it "should set the default language" do
        controller.stub(:params).and_return({})
        controller.send :set_alchemy_language
        assigns(:language).should == default_language
        expect(Alchemy::Language.current).to eq(default_language)
        expect(controller.session).to include_language_information_for(default_language)
      end
    end

    context "with language in the session" do
      before do
        controller.stub(:session).and_return(alchemy_language_id: klingonian.id)
        Alchemy::Language.stub(current: klingonian)
      end

      it "should use the language from the session" do
        controller.send :set_alchemy_language
        assigns(:language).should == klingonian
        expect(Alchemy::Language.current).to eq(klingonian)
      end
    end

    context "with lang param" do
      it "should set the language" do
        controller.stub(:params).and_return(lang: klingonian.code)
        controller.send :set_alchemy_language
        assigns(:language).should == klingonian
        expect(Alchemy::Language.current).to eq(klingonian)
        expect(controller.session).to include_language_information_for(klingonian)
      end

      context "for language that does not exist" do
        before do
          controller.stub(:params).and_return(lang: 'fo')
          controller.send :set_alchemy_language
        end

        it "should set the language to default" do
          assigns(:language).should == default_language
          expect(Alchemy::Language.current).to eq(default_language)
          expect(controller.session).to include_language_information_for(default_language)
        end
      end
    end
  end
end
