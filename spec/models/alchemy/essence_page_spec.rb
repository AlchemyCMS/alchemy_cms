# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::EssencePage, type: :model do
  let(:essence) { build(:alchemy_essence_page) }
  let(:page) { essence.page }

  it_behaves_like "an essence" do
    let(:ingredient_value) { page }
  end

  describe "eager loading" do
    let!(:essence_pages) { create_list(:alchemy_essence_page, 2) }

    it "eager loads pages" do
      essences = described_class.all.includes(:ingredient_association)
      expect(essences[0].association(:ingredient_association)).to be_loaded
    end
  end
end
