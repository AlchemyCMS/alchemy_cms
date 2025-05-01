# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::BooleanView, type: :component do
  subject do
    render_inline described_class.new(ingredient)
    page
  end

  context "with true as value" do
    let(:ingredient) { Alchemy::Ingredients::Boolean.new(value: true) }

    it "renders true" do
      is_expected.to have_content("True")
    end
  end

  context "with false as value" do
    let(:ingredient) { Alchemy::Ingredients::Boolean.new(value: false) }

    it "renders false" do
      is_expected.to have_content("False")
    end
  end

  context "with nil as value" do
    let(:ingredient) { Alchemy::Ingredients::Boolean.new(value: nil) }

    it "renders nothing" do
      is_expected.to have_content("")
    end
  end
end
