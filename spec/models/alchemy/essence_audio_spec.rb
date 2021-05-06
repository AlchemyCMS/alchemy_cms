# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::EssenceAudio do
  let(:attachment) { create(:alchemy_attachment) }
  let(:essence) { described_class.new(attachment: attachment) }

  it_behaves_like "an essence" do
    let(:ingredient_value) { attachment }
  end
end
