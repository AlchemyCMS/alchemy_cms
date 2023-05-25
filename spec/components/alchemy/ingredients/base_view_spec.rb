require "rails_helper"

RSpec.describe Alchemy::Ingredients::BaseView do
  describe "#settings_value" do
    let(:element) { Alchemy::Element.new(name: "article") }
    let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }
    let(:ingredient_view) { Alchemy::Ingredients::TextView.new(ingredient) }
    let(:key) { :anchor }
    let(:default) { nil }

    subject { ingredient_view.send(:settings_value, key, value: value, default: default) }

    context "without value" do
      let(:value) { nil }

      context "and ingredient having setting for key" do
        it "returns the value for key from ingredient settings" do
          expect(subject).to eq("from_value")
        end
      end

      context "but ingredient having no setting for key" do
        let(:key) { :foo }

        context "but default given" do
          let(:default) { "baz" }

          it "returns the default value" do
            expect(subject).to eq("baz")
          end
        end

        context "and no default" do
          let(:default) { nil }

          it { expect(subject).to be_nil }
        end
      end
    end

    context "with value" do
      let(:value) { "a-value" }

      it "returns the value" do
        expect(subject).to eq("a-value")
      end
    end
  end
end
