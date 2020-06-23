# frozen_string_literal: true

require "rails_helper"

describe Alchemy::ConfigurationMethods do
  let(:controller) do
    class SomeController < ActionController::Base
      include Alchemy::ConfigurationMethods
    end

    SomeController.new
  end

  describe "#prefix_locale?" do
    subject { controller.prefix_locale? }

    context "if no languages are present" do
      it { is_expected.to be false }
    end

    context "if one language is present" do
      let!(:language) { create(:alchemy_language) }

      it { is_expected.to be false }
    end

    context "if more than one language is present" do
      let!(:german) { create(:alchemy_language, :german, default: true) }
      let!(:english) { create(:alchemy_language, :english) }

      subject { controller.prefix_locale?(args) }

      around do |example|
        old_locale = I18n.default_locale
        ::I18n.default_locale = "de"
        example.run
        ::I18n.default_locale = old_locale
      end

      context "and it is called with the default language" do
        let(:args) { "de" }
        it { is_expected.to be false }
      end

      context "and it is called with the non-default language" do
        let(:args) { "en" }

        it { is_expected.to be true }
      end

      context "and it is called with bogus stuff" do
        let(:args) { "kl" }

        it { is_expected.to be true }
      end
    end
  end
end
