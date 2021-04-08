# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::EssenceHeadline do
  subject(:essence) do
    Alchemy::EssenceHeadline.new(
      body: ingredient_value,
      level: 2,
      size: 3
    )
  end

  let(:ingredient_value) { "A headline" }

  it_behaves_like "an essence"

  describe "#level_options" do
    subject { essence.level_options }

    it { is_expected.to eq([["H1", 1], ["H2", 2], ["H3", 3], ["H4", 4], ["H5", 5], ["H6", 6]]) }

    context "when restricted through the essence settings" do
      before do
        expect(essence).to receive_message_chain(:content, :settings).and_return(levels: [2, 3])
      end

      it { is_expected.to eq([["H2", 2], ["H3", 3]]) }
    end
  end

  describe "#size_options" do
    subject { essence.size_options }

    it { is_expected.to eq([]) }

    context "when enabled through the essence settings" do
      before do
        expect(essence).to receive_message_chain(:content, :settings).and_return(sizes: [3, 4])
      end

      it { is_expected.to eq([["H3", 3], ["H4", 4]]) }
    end
  end

  describe "initialization" do
    describe "level" do
      subject { Alchemy::EssenceHeadline.new.level }

      it { is_expected.to eq(1) }
    end

    describe "size" do
      let(:content) { build(:alchemy_content) }
      let(:essence) { Alchemy::EssenceHeadline.new(content: content) }
      subject { essence.size }

      it { is_expected.to be_nil }

      context "when enabled through the essence settings" do
        before do
          expect(content).to receive(:settings).and_return(sizes: [3, 4]).twice
        end

        it { is_expected.to eq(3) }
      end
    end
  end

  describe "creating from a content" do
    it "should have the size and level fields filled with correct defaults" do
      element = create(:alchemy_element)

      allow(element).to receive(:content_definition_for) do
        {
          "name" => "headline",
          "type" => "EssenceHeadline",
          "settings" => {
            "sizes" => [3],
            "levels" => [2, 3],
          },
        }.with_indifferent_access
      end

      content = Alchemy::Content.create(element: element, name: "headline")
      expect(content.essence.size).to eq(3)
      expect(content.essence.level).to eq(2)
    end
  end
end
