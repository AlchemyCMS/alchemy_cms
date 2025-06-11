# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe IngredientDefinition do
    describe "#attributes" do
      let(:definition) { described_class.new(role: "text") }

      subject { definition.attributes }

      it { is_expected.to have_key(:role) }
      it { is_expected.to have_key(:type) }
      it { is_expected.to have_key(:as_element_title) }
      it { is_expected.to have_key(:settings) }
      it { is_expected.to have_key(:validate) }
      it { is_expected.to have_key(:group) }
      it { is_expected.to have_key(:default) }
      it { is_expected.to have_key(:deprecated) }
      it { is_expected.to have_key(:hint) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:role) }
      it { is_expected.to allow_value("text_block").for(:role) }
      it { is_expected.to_not allow_value("Text Block").for(:role) }

      it { is_expected.to validate_presence_of(:type) }
      it { is_expected.to allow_value("SpreeProduct").for(:type) }
      it { is_expected.to_not allow_value("spree product").for(:type) }
      it { is_expected.to_not allow_value("spree_product").for(:type) }
      it { is_expected.to_not allow_value("Spree::Product").for(:type) }
    end

    it_behaves_like "having a hint" do
      let(:translation_key) { "text" }
      let(:translation_scope) { :ingredient_hints }

      let(:subject) do
        described_class.new(role: "text", **hint)
      end
    end

    describe "#deprecation_notice" do
      subject { definition.deprecation_notice(element_name: element&.name) }

      let(:element) { nil }

      context "when ingredient is not deprecated" do
        let(:definition) { described_class.new(role: "text") }

        it { is_expected.to be_nil }
      end

      context "when ingredient is deprecated" do
        context "with String as deprecation" do
          let(:definition) do
            described_class.new(
              role: "foo",
              deprecated: "Ingredient is deprecated"
            )
          end

          it "returns depraction notice" do
            is_expected.to eq("Ingredient is deprecated")
          end
        end

        context "without custom ingredient translation" do
          let(:definition) do
            described_class.new(
              role: "foo",
              deprecated: true
            )
          end

          it "returns depraction notice" do
            is_expected.to eq(
              "WARNING! This field is deprecated and will be removed soon. " \
              "Please do not use it anymore."
            )
          end
        end

        context "with custom ingredient translation" do
          let(:element) { build(:alchemy_element, name: "all_you_can_eat") }

          let(:definition) do
            described_class.new(
              role: "html",
              deprecated: true
            )
          end

          it { is_expected.to eq("Old ingredient is deprecated") }
        end
      end
    end

    describe "#settings" do
      subject(:settings) { described_class.new.settings }

      it "have indifferent access" do
        expect(settings).to be_an(HashWithIndifferentAccess)
      end
    end

    describe "#validate" do
      subject(:validate) { definition.validate }

      context "with definition having hash validation" do
        let(:definition) do
          described_class.new(validate: [{length: {minimum: 1, maximum: 3}}])
        end

        it "validation has indifferent access" do
          expect(validate[0]).to be_an(HashWithIndifferentAccess)
        end
      end

      context "with definition having String validation" do
        let(:definition) do
          described_class.new(validate: ["presence"])
        end

        it { expect(validate[0]).to be_an(String) }
      end

      context "with definition having String validation" do
        let(:definition) do
          described_class.new(validate: [:presence])
        end

        it { expect(validate[0]).to be_an(Symbol) }
      end
    end
  end
end
