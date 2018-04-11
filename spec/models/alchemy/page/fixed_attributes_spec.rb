# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Alchemy::Page::FixedAttributes do
  let(:page) { Alchemy::Page.new }

  let(:definition_with_fixed_attributes) do
    {
      'name' => 'foo',
      'fixed_attributes' => {
        name: 'Home'
      }
    }
  end

  let(:definition_without_fixed_attributes) do
    {
      'name' => 'foo'
    }
  end

  describe '#all' do
    it 'is an alias to attributes' do
      described_class.new(page).attributes == described_class.new(page).all
    end
  end

  describe '#attributes' do
    subject(:attributes) do
      described_class.new(page).attributes
    end

    it 'returns empty hash' do
      expect(attributes).to eq({})
    end

    context 'with page having fixed_attributes defined' do
      before do
        allow(page).to receive(:definition) do
          definition_with_fixed_attributes
        end
      end

      it 'returns fixed attributes from page definition' do
        expect(attributes).to eq({name: 'Home'})
      end
    end
  end

  describe '#any?' do
    subject(:any?) do
      described_class.new(page).any?
    end

    context 'when fixed attributes are defined' do
      before do
        allow(page).to receive(:definition) do
          definition_with_fixed_attributes
        end
      end

      it { is_expected.to eq(true) }
    end

    context 'when fixed attributes are not defined' do
      before do
        allow(page).to receive(:definition) do
          definition_without_fixed_attributes
        end
      end

      it { is_expected.to eq(false) }
    end

    it 'has a `present?` alias' do
      described_class.new(page).any? == described_class.new(page).present?
    end
  end

  describe '#fixed?' do
    subject(:fixed?) do
      described_class.new(page).fixed?(name)
    end

    context 'with nil given as name' do
      let(:name) { nil }

      it { is_expected.to eq(false) }
    end

    context 'with name not defined as fixed attribute' do
      let(:name) { 'lol' }

      it { is_expected.to eq(false) }
    end

    context 'with name defined as fixed attribute' do
      let(:name) { :name }

      before do
        allow(page).to receive(:definition) do
          definition_with_fixed_attributes
        end
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#[]' do
    subject(:fetch) do
      described_class.new(page)[name]
    end

    context 'with nil given as name' do
      let(:name) { nil }

      it { is_expected.to be(nil) }
    end

    context 'with name not defined as fixed attribute' do
      let(:name) { 'lol' }

      it { is_expected.to be(nil) }
    end

    context 'with name defined as fixed attribute' do
      let(:name) { :name }

      before do
        allow(page).to receive(:definition) do
          definition_with_fixed_attributes
        end
      end

      it 'returns the value' do
        is_expected.to eq('Home')
      end
    end
  end
end
