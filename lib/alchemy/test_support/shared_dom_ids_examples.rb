# frozen_string_literal: true

RSpec.shared_examples_for "having dom ids" do
  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }

  let(:ingredient) do
    described_class.new(
      element: element,
      role: "headline",
    )
  end

  describe "setting dom id from value" do
    subject do
      ingredient.valid? && ingredient.dom_id
    end

    before do
      expect_any_instance_of(described_class).to receive(:settings).at_least(:once) { settings }
    end

    context "without anchor settings" do
      let(:settings) do
        {}
      end

      it "does not set a dom_id" do
        is_expected.to be_nil
      end
    end

    context "with anchor setting set to true" do
      let(:settings) do
        { anchor: true }
      end

      it "parameterizes dom_id" do
        ingredient.dom_id = "SE Headline"
        is_expected.to eq "se-headline"
      end
    end

    context "with anchor setting set to from_value" do
      let(:settings) do
        { anchor: "from_value" }
      end

      context "with a value present" do
        let(:ingredient) do
          described_class.new(
            element: element,
            role: "headline",
            value: "Hello World",
          )
        end

        it "sets a dom_id from value" do
          is_expected.to eq "hello-world"
        end
      end

      context "with no value present" do
        let(:ingredient) do
          described_class.new(
            element: element,
            role: "headline",
            value: "",
          )
        end

        it "sets no dom_id" do
          is_expected.to eq ""
        end
      end
    end

    context "with anchor setting set to fixed value" do
      context "that is false" do
        let(:settings) do
          { anchor: false }
        end

        it "sets no dom_id" do
          is_expected.to be_nil
        end
      end

      context "that is true" do
        let(:settings) do
          { anchor: true }
        end

        it "sets no dom_id" do
          is_expected.to be_nil
        end
      end

      context "that is from_value" do
        let(:settings) do
          { anchor: true }
        end

        it "sets no dom_id" do
          is_expected.to be_nil
        end
      end

      context "that is a non reserved value" do
        let(:settings) do
          { anchor: "FixED VALUE" }
        end

        it "sets the dom_id to fixed value" do
          is_expected.to eq "fixed-value"
        end
      end
    end
  end
end
