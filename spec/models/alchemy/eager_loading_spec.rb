# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::EagerLoading do
  describe ".page_includes" do
    context "with no version param given" do
      subject { described_class.page_includes }

      it "returns public version includes" do
        is_expected.to match_array([
          :tags,
          {
            language: :site,
            public_version: {
              elements: [
                :page,
                :touchable_pages,
                {
                  ingredients: :related_object,
                  contents: :essence,
                },
              ],
            },
          },
        ])
      end
    end

    context "with version param given" do
      subject { described_class.page_includes(version: :draft_version) }

      it "returns version includes" do
        is_expected.to match_array([
          :tags,
          {
            language: :site,
            draft_version: {
              elements: [
                :page,
                :touchable_pages,
                {
                  ingredients: :related_object,
                  contents: :essence,
                },
              ],
            },
          },
        ])
      end
    end

    context "with unknown version param given" do
      subject { described_class.page_includes(version: :foo_baz) }

      it "returns version includes" do
        expect { subject }.to raise_error(Alchemy::UnsupportedPageVersion)
      end
    end
  end
end
