# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementsRepository do
  let(:repo) { described_class.new(elements) }
  let(:visible_element) { build_stubbed(:alchemy_element, name: "headline") }
  let(:hidden_element) { build_stubbed(:alchemy_element, public: false) }
  let(:fixed_element) { build_stubbed(:alchemy_element, fixed: true) }
  let(:folded_element) { build_stubbed(:alchemy_element, folded: true) }
  let(:nested_element) { build_stubbed(:alchemy_element, parent_element: visible_element) }
  let(:elements) { [visible_element, hidden_element, fixed_element, folded_element, nested_element] }

  it { expect(repo).to be_an(Enumerable) }

  shared_examples "being chainable" do
    it "is chainable" do
      expect(subject).to be_an(described_class)
    end
  end

  describe ".none" do
    subject { described_class.none }

    it "returns empty set of elements" do
      expect(subject.to_a).to eq([])
    end

    it_behaves_like "being chainable"
  end

  describe "#visible" do
    subject { repo.visible }

    it "returns only visible elements" do
      is_expected.to match_array([visible_element, fixed_element, folded_element, nested_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#hidden" do
    subject { repo.hidden }

    it "returns only hidden elements" do
      is_expected.to match_array([hidden_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#named" do
    let(:names) { [] }

    subject { repo.named(names) }

    it_behaves_like "being chainable"

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
    let(:attrs) { {} }

    subject { repo.where(attrs) }

    it_behaves_like "being chainable"

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
    let(:names) { [] }

    subject { repo.excluded(names) }

    it_behaves_like "being chainable"

    context "with a single string" do
      let(:names) { "headline" }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element, nested_element])
      end
    end

    context "with a single symbol" do
      let(:names) { :headline }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element, nested_element])
      end
    end

    context "with an array of strings" do
      let(:names) { %w[headline] }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element, nested_element])
      end
    end

    context "with an array of symbols" do
      let(:names) { %i[headline] }

      it "returns only elements without given name" do
        is_expected.to match_array([hidden_element, fixed_element, folded_element, nested_element])
      end
    end
  end

  describe "#fixed" do
    subject { repo.fixed }

    it "returns only fixed elements" do
      is_expected.to match_array([fixed_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#unfixed" do
    subject { repo.unfixed }

    it "returns only not fixed elements" do
      is_expected.to match_array([visible_element, hidden_element, folded_element, nested_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#folded" do
    subject { repo.folded }

    it "returns only folded elements" do
      is_expected.to match_array([folded_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#expanded" do
    subject { repo.expanded }

    it "returns only expanded elements" do
      is_expected.to match_array([visible_element, hidden_element, fixed_element, nested_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#not_nested" do
    subject { repo.not_nested }

    it "returns only top level not nested elements" do
      is_expected.to match_array([visible_element, hidden_element, fixed_element, folded_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#reverse" do
    subject { repo.reverse }

    it "returns elements in reverse order" do
      expect(subject.to_a).to eq([nested_element, folded_element, fixed_element, hidden_element, visible_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#random" do
    subject { repo.random }

    it "returns elements in random order" do
      expect_any_instance_of(Array).to receive(:shuffle).and_call_original
      subject
    end

    it_behaves_like "being chainable"
  end

  describe "#offset" do
    subject { repo.offset(2) }

    it "returns elements offsetted" do
      is_expected.to match_array([fixed_element, folded_element, nested_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#limit" do
    subject { repo.limit(2) }

    it "returns elements limitted" do
      is_expected.to match_array([visible_element, hidden_element])
    end

    it_behaves_like "being chainable"
  end

  describe "#children_of" do
    subject { repo.children_of(visible_element) }

    it { is_expected.to match_array([nested_element]) }
  end
end
