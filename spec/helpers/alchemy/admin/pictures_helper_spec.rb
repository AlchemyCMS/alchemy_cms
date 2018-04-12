# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::Admin::PicturesHelper do
  describe "#create_or_assign_url" do
    let(:picture) { mock_model('Picture') }
    let(:options) { Hash.new }

    before { @element = mock_model('Element') }

    it "should return a Hash" do
      expect(helper.create_or_assign_url(picture, options)).to be_a(Hash)
    end

    context "when creating" do
      it "should include 'create' as the value for the action key" do
        expect(helper.create_or_assign_url(picture, options)[:action]).to be(:create)
      end
    end

    context "when assigning" do
      before { @content = mock_model('Content') }

      it "should include 'assign' as the value for the action key" do
        expect(helper.create_or_assign_url(picture, options)[:action]).to be(:assign)
      end
    end
  end

  describe "#preview_size" do
    subject { helper.preview_size(size) }

    context "when 'small' is passed in" do
      let(:size) { 'small' }

      it { is_expected.to eq('80x60') }
    end

    context "when 'large' is passed in" do
      let(:size) { 'large' }

      it { is_expected.to eq('240x180') }
    end

    context "when anything else is passed in" do
      let(:size) { nil }

      it { is_expected.to eq('160x120') }
    end
  end
end
