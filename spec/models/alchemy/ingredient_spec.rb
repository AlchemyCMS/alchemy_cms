# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredient do
  describe "validations" do
    let!(:other_ingredient) { create(:alchemy_ingredient_text) }

    it { is_expected.to validate_uniqueness_of(:role).scoped_to(:element_id).case_insensitive }
  end

  let(:element) do
    build(:alchemy_element, name: "article", autogenerate_ingredients: false)
  end

  it_behaves_like "having a hint" do
    let(:subject) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }
  end

  describe "scopes" do
    let(:element) do
      build(:alchemy_element, name: "all_you_can_eat", autogenerate_ingredients: false)
    end

    %w[
      audio
      boolean
      datetime
      file
      headline
      html
      link
      node
      page
      picture
      richtext
      select
      text
      video
    ].each do |type|
      describe ".#{type}s" do
        subject { described_class.send(type.pluralize) }

        let(type.to_sym) { "Alchemy::Ingredients::#{type.classify}".constantize.create(role: type, element: element) }
        let!(:ingredients) { [public_send(type)] }

        it "returns only #{type} ingredients" do
          is_expected.to eq([public_send(type)])
        end
      end
    end
  end

  describe ".normalize_type" do
    subject { described_class.normalize_type("Text") }

    it "returns full ingredient constant name" do
      is_expected.to eq("Alchemy::Ingredients::Text")
    end
  end

  describe ".allow_settings" do
    subject(:allow_settings) { described_class.allow_settings(:linkable) }

    it "sets allowed_settings" do
      allow_settings
      expect(described_class.allowed_settings).to eq([:linkable])
    end
  end

  describe "#settings" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }

    it "returns the settings hash from definition" do
      expect(ingredient.settings).to eq({"anchor" => "from_value"})
    end

    context "if settings are not defined" do
      let(:ingredient) { Alchemy::Ingredients::Text.new(role: "text", element: element) }

      it "returns empty hash" do
        expect(ingredient.settings).to eq({})
      end
    end
  end

  describe "#partial_name" do
    let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", element: element) }

    subject { ingredient.partial_name }

    it "returns the demodulized underscored class name" do
      is_expected.to eq "richtext"
    end
  end

  describe "#to_partial_path" do
    let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", element: element) }

    subject { ingredient.to_partial_path }

    it "returns the path to the view partial" do
      is_expected.to eq "alchemy/ingredients/richtext_view"
    end
  end

  describe "#has_validations?" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }

    subject { ingredient.has_validations? }

    context "not defined with validations" do
      it { is_expected.to be false }
    end

    context "defined with validations" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once).and_return({
          validate: {presence: true}
        })
      end

      it { is_expected.to be true }
    end
  end

  describe "#has_hint?" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }

    subject { ingredient.has_hint? }

    context "not defined with hint" do
      it { is_expected.to be false }
    end

    context "defined with hint" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once).and_return({
          hint: true
        })
      end

      it { is_expected.to be true }
    end
  end

  describe "#deprecated?" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }

    subject { ingredient.deprecated? }

    context "not defined as deprecated" do
      it { is_expected.to be false }
    end

    context "defined as deprecated" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once).and_return({
          deprecated: true
        })
      end

      it { is_expected.to be true }
    end

    context "defined as deprecated per String" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once).and_return({
          deprecated: "This ingredient is deprecated"
        })
      end

      it { is_expected.to be true }
    end
  end

  describe "#preview_ingredient?" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }

    subject { ingredient.preview_ingredient? }

    context "not defined as as_element_title" do
      it { is_expected.to be false }
    end

    context "defined as as_element_title" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once).and_return({
          as_element_title: true
        })
      end

      it { is_expected.to be true }
    end
  end

  describe "#has_tinymce?" do
    subject { ingredient.has_tinymce? }

    let(:ingredient) { Alchemy::Ingredients::Headline.new(role: "headline", element: element) }

    it { is_expected.to be(false) }
  end

  describe "#as_view_component" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "intro", element: element) }

    it "passes options as keyword arguments to view component class" do
      expect(Alchemy::Ingredients::TextView).to receive(:new).with(ingredient, disable_link: true, html_options: {class: "foo"})
      ingredient.as_view_component(
        options: {disable_link: true},
        html_options: {class: "foo"}
      )
    end
  end

  describe "#preload_relations" do
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "intro", element: element) }

    subject { ingredient.preload_relations }

    it { is_expected.to eq([]) }
  end
end
