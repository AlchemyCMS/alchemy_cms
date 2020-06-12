# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureVariant do
  let(:alchemy_picture) { build_stubbed(:alchemy_picture) }

  it_behaves_like "has image transformations" do
    let(:picture) { described_class.new(alchemy_picture) }
  end
end
