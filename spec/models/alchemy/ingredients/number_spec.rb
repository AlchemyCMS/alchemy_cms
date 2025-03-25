# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Number do
  it_behaves_like "an alchemy ingredient"

  describe ".allow_settings" do
    it do
      expect(described_class.allowed_settings).to eq %i[
        input_type
        step
        min
        max
        unit
      ]
    end
  end
end
