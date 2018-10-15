# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::Admin::PicturesHelper do
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
