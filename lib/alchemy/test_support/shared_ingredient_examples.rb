# frozen_string_literal: true

require "shoulda-matchers"

RSpec.shared_examples_for "an alchemy ingredient" do
  let(:element) { build(:alchemy_element, name: "article") }

  subject(:ingredient) do
    described_class.new(
      element: element,
      role: "headline"
    )
  end

  it { is_expected.to belong_to(:element).touch(true).class_name("Alchemy::Element") }
  it { is_expected.to belong_to(:related_object).optional }
  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:type) }

  describe "#settings" do
    subject { ingredient.settings }

    context "without element" do
      let(:element) { nil }

      it { is_expected.to eq({}) }
    end

    context "with element" do
      before do
        expect(element).to receive(:ingredient_definition_for).at_least(:once) do
          Alchemy::IngredientDefinition.new(
            settings: {
              linkable: true
            }
          )
        end
      end

      it { is_expected.to eq({linkable: true}.with_indifferent_access) }
    end
  end

  describe "#definition" do
    subject { ingredient.definition }

    context "without element" do
      let(:element) { nil }

      it { is_expected.to be_a(Alchemy::IngredientDefinition) }
    end

    context "with element" do
      let(:definition) do
        Alchemy::IngredientDefinition.new(
          role: "headline",
          type: "Text",
          default: "Hello World",
          settings: {
            linkable: true
          }
        )
      end

      before do
        expect(element).to receive(:ingredient_definition_for).at_least(:once) do
          definition
        end
      end

      it "returns ingredient definition" do
        is_expected.to eq(definition)
      end
    end
  end

  describe "#as_view_component" do
    subject { ingredient.as_view_component }

    it { is_expected.to be_a("#{described_class}View".constantize) }
  end
end

# Shared by the ingredients that store an editor supplied url.
#
#   it_behaves_like "a linkable alchemy ingredient", :link
#
RSpec.shared_examples_for "a linkable alchemy ingredient" do |url_attribute|
  describe "url scheme validation" do
    let(:element) { build(:alchemy_element, name: "article") }

    subject(:ingredient) do
      described_class.new(element: element, role: "headline")
    end

    # captured in a let, a block parameter is not in scope inside a def
    let(:attribute) { url_attribute }

    def errors_for(url)
      ingredient.public_send(:"#{attribute}=", url)
      ingredient.valid?
      ingredient.errors[attribute]
    end

    it "allows a blank url" do
      expect(errors_for(nil)).to be_empty
    end

    it "allows an allowed scheme" do
      expect(errors_for("https://example.com")).to be_empty
      expect(errors_for("mailto:jane@example.com")).to be_empty
    end

    it "allows a relative url" do
      expect(errors_for("/a/path")).to be_empty
      expect(errors_for("#an-anchor")).to be_empty
    end

    it "rejects an executable scheme" do
      expect(errors_for("javascript:alert(document.domain)")).to be_present
      expect(errors_for("data:text/html;base64,PHN2Zz4=")).to be_present
      expect(errors_for("vbscript:msgbox(1)")).to be_present
    end

    it "rejects an executable scheme obfuscated by whitespace" do
      expect(errors_for(" javascript:alert(1)")).to be_present
      expect(errors_for("java\tscript:alert(1)")).to be_present
    end

    it "rejects a javascript url disguised as an authority" do
      expect(errors_for("javascript://%0aalert(1)")).to be_present
    end
  end
end
