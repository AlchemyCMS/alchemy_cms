# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe ".t" do
    it "scopes translations intro alchemy namespace" do
      expect(::I18n).to receive(:t).with(:foo, default: "Foo", scope: ["alchemy"])
      ::Alchemy.t(:foo)
    end
  end

  describe ".l" do
    it "delegates to Alchemy::I18n.localize" do
      time = Time.current
      expect(Alchemy::I18n).to receive(:localize).with(time, format: "foo")
      Alchemy.l(time, format: "foo")
    end
  end

  describe I18n do
    describe ".available_locales" do
      subject { I18n.available_locales }
      it { is_expected.to be_a Array }
      it { is_expected.to include(:en) }

      context "when locales are already set in application available_locales" do
        it "returns them" do
          expect(Rails.application.config.i18n).to receive(:available_locales) { [:de, :it] }
          is_expected.to match_array([:de, :it])
        end
      end

      context "when locales are already set in @@available_locales" do
        before { I18n.class_variable_set(:@@available_locales, [:kl, :jp]) }
        it { is_expected.to match_array([:kl, :jp]) }
        after { I18n.class_variable_set(:@@available_locales, nil) }
      end

      context "when locales are present in other gems" do
        before do
          expect(::I18n).to receive(:load_path) do
            ["/Users/tvd/gems/alchemy_i18n/config/locales/alchemy.de.yml"]
          end
        end

        it "includes them" do
          is_expected.to eq([:de])
        end
      end

      context "when same locales are present in multiple gems" do
        before do
          expect(::I18n).to receive(:load_path) do
            [
              "/Users/tvd/gems/alchemy-devise/config/locales/alchemy.de.yml",
              "/Users/tvd/gems/alchemy_i18n/config/locales/alchemy.de.yml"
            ]
          end
        end

        it "includes them only once" do
          is_expected.to eq([:de])
        end
      end

      context "when locales have long iso format" do
        before do
          expect(::I18n).to receive(:load_path) do
            ["/Users/tvd/gems/alchemy_i18n/config/locales/alchemy.zh-CN.yml"]
          end
        end

        it "includes them in long format" do
          is_expected.to eq([:"zh-CN"])
        end
      end

      context "multiple locales" do
        before do
          expect(::I18n).to receive(:load_path) do
            [
              "/Users/tvd/gems/alchemy_i18n/config/locales/alchemy.zh-CN.yml",
              "/Users/tvd/gems/alchemy_i18n/config/locales/alchemy.de.yml"
            ]
          end
        end

        it "are sorted" do
          is_expected.to eq([:de, :"zh-CN"])
        end
      end
    end

    describe ".available_locales=" do
      it "assigns the given locales to @@available_locales" do
        I18n.available_locales = [:kl, :nl, :cn]
        expect(I18n.class_variable_get(:@@available_locales)).to eq([:kl, :nl, :cn])
      end
    end

    describe ".localize" do
      subject(:localize) { Alchemy::I18n.localize(date) }

      let(:date) { Date.new(2026, 9, 22) }

      context "with just a date given" do
        it "localizes by default alchemy date format" do
          is_expected.to eq("2026-09-22")
        end
      end

      context "with date and format given" do
        subject(:localize) { Alchemy::I18n.localize(date, format: ":foo") }

        it "localizes by given format" do
          is_expected.to eq(":foo")
        end
      end

      context "with time given" do
        let(:date) { Time.new(2026, 9, 22, 11, 43, 0, 0) }

        it "localizes with default alchemy time format" do
          is_expected.to eq("22-09-2026 11:43am")
        end
      end

      context "with nil given" do
        let(:date) { nil }

        it { is_expected.to be_nil }
      end
    end
  end
end
