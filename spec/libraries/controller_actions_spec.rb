# frozen_string_literal: true

require "rails_helper"

describe "Alchemy::ControllerActions", type: "controller" do
  # Anonymous controller to test the integration against
  controller(ActionController::Base) do
    include Alchemy::ControllerActions
  end

  describe "#current_alchemy_user" do
    context "with default current_user_method" do
      it "calls current_user by default" do
        expect(controller).to receive :current_user
        controller.send :current_alchemy_user
      end
    end

    context "with custom current_user_method" do
      before do
        stub_config(Alchemy, {current_user_method: :current_admin})
      end

      it "calls the custom method" do
        expect(controller).to receive :current_admin
        controller.send :current_alchemy_user
      end
    end

    context "with not implemented current_user_method" do
      before do
        stub_config(Alchemy, {current_user_method: :not_implemented_method})
      end

      it "raises an error" do
        expect {
          controller.send :current_alchemy_user
        }.to raise_error(Alchemy::NoCurrentUserFoundError)
      end
    end
  end

  describe "#set_alchemy_language" do
    let!(:default_language) { create(:alchemy_language, code: :en) }
    let(:klingon) { create(:alchemy_language, :klingon) }

    after do
      # We must never change the app's locale
      expect(::I18n.locale).to eq(:en)
      # Reset the current language so its fresh for every subsequent test
      Alchemy::Current.language = nil
    end

    context "with a Language object given" do
      it "should set the language to the Language instance" do
        controller.send :set_alchemy_language, klingon
        expect(assigns(:language)).to eq(klingon)
        expect(Alchemy::Current.language).to eq(klingon)
      end
    end

    context "with a language id given" do
      it "should find and set the language by the id" do
        controller.send :set_alchemy_language, klingon.id
        expect(assigns(:language)).to eq(klingon)
        expect(Alchemy::Current.language).to eq(klingon)
      end
    end

    context "with a locale given" do
      it "should find and set the language by the locale" do
        controller.send :set_alchemy_language, klingon.code
        expect(assigns(:language)).to eq(klingon)
        expect(Alchemy::Current.language).to eq(klingon)
      end
    end

    context "with no lang param" do
      it "should set the default language" do
        allow(controller).to receive(:params).and_return({})
        controller.send :set_alchemy_language
        expect(assigns(:language)).to eq(default_language)
        expect(Alchemy::Current.language).to eq(default_language)
      end
    end

    context "with lang param" do
      it "should set the language" do
        allow(controller).to receive(:params).and_return(locale: klingon.code)
        controller.send :set_alchemy_language
        expect(assigns(:language)).to eq(klingon)
        expect(Alchemy::Current.language).to eq(klingon)
      end

      context "for language that does not exist" do
        before do
          allow(controller).to receive(:params).and_return(locale: "fo")
        end

        it "should raise an error" do
          expect do
            controller.send :set_alchemy_language
          end.to raise_exception(ActionController::RoutingError, "Language not found")
        end
      end
    end
  end
end
