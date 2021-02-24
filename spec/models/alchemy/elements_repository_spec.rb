# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementsRepository do
  let(:repo) { described_class.new(elements) }
  let(:visible_element) { create(:alchemy_element, name: "headline") }
  let(:hidden_element) { create(:alchemy_element, public: false) }
  let(:fixed_element) { create(:alchemy_element, fixed: true) }
  let(:folded_element) { create(:alchemy_element, folded: true) }
  let(:elements) { [visible_element, hidden_element, fixed_element, folded_element] }

  it { expect(repo).to be_an(Enumerable) }

  describe "#visible" do
    subject { repo.visible }

    it "returns only visible elements" do
      is_expected.to match_array([visible_element, fixed_element, folded_element])
    end
  end

  describe "#hidden" do
    subject { repo.hidden }

    it "returns only hidden elements" do
      is_expected.to match_array([hidden_element])
    end
  end

  describe "#named" do
    let(:names) { [] }

    subject { repo.named(names) }

    context "with a single string" do
      let(:names) { "headline" }

      it "returns only elements with given name" do
        is_expected.to match_array([visible_element])
      end
    end

    context "with a single symbol" do
      let(:names) { :headline }

      it "returns only elements with given name" do
        is_expected.to match_array([visible_element])
      end
    end

    context "with an array of strings" do
      let(:names) { %w[headline] }

      it "returns only elements with given name" do
        is_expected.to match_array([visible_element])
      end
    end

    context "with an array of symbols" do
      let(:names) { %i[headline] }

      it "returns only elements with given name" do
        is_expected.to match_array([visible_element])
      end
    end
  end

  describe "#where" do
    subject { repo.where(attrs) }

    context "with a single key hash" do
      let(:attrs) { { name: "headline" } }

      it "returns only elements matching attribute and value" do
        is_expected.to match_array([visible_element])
      end
    end

    context "with a multi key hash" do
      let(:attrs) { { name: "headline", public: false } }

      it "returns only elements matching all attributes and values" do
        is_expected.to match_array([])
      end
    end
  end

  describe "#excluded" do
    subject { repo.excluded(names) }

    context "with a single string" do
      let(:names) { "headline" }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element])
      end
    end

    context "with a single symbol" do
      let(:names) { :headline }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element])
      end
    end

    context "with an array of strings" do
      let(:names) { %w[headline] }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element])
      end
    end

    context "with an array of symbols" do
      let(:names) { %i[headline] }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element])
      end
    end
  end

  describe "#fixed" do
    subject { repo.fixed }

    it "returns only fixed elements" do
      is_expected.to match_array([fixed_element])
    end
  end

  describe "#unfixed" do
    subject { repo.unfixed }

    it "returns only not fixed elements" do
      is_expected.to match_array([visible_element, hidden_element, folded_element])
    end
  end

  describe "#folded" do
    subject { repo.folded }

    it "returns only folded elements" do
      is_expected.to match_array([folded_element])
    end
  end

  describe "#expanded" do
    subject { repo.expanded }

    it "returns only expanded elements" do
      is_expected.to match_array([visible_element, hidden_element, fixed_element])
    end
  end
end
