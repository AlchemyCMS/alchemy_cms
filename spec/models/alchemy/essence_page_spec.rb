# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alchemy::EssencePage, type: :model do
  let(:essence) { build(:alchemy_essence_page) }
  let(:page) { essence.page }

  it_behaves_like "an essence" do
    let(:ingredient_value) { page }
  end

  describe 'ingredient=' do
    subject(:ingredient) { essence.page }

    context 'when value is a String matching a number' do
      let(:value) { '101' }

      before do
        essence.ingredient = value
      end

      it 'sets page to an page instance with that id' do
        is_expected.to be_a(Alchemy::Page)
        expect(ingredient.id).to eq(101)
      end
    end

    context 'when value is an Alchemy Page' do
      let(:value) { page }

      before do
        essence.ingredient = value
      end

      it 'sets page to an page instance with that id' do
        is_expected.to be_a(Alchemy::Page)
        expect(ingredient).to eq(page)
      end
    end

    context 'when value is something else' do
      let(:value) { 'something' }

      it do
        expect {
          essence.ingredient = value
        }.to raise_error(ActiveRecord::AssociationTypeMismatch)
      end
    end
  end
end
