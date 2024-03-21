# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureDescription do
  it { should belong_to(:picture).class_name("Alchemy::Picture") }
  it { should belong_to(:language).class_name("Alchemy::Language") }

  describe "validations" do
    let(:picture) { create(:alchemy_picture) }
    let(:language) { create(:alchemy_language) }

    let!(:description) do
      described_class.create!(picture: picture, language: language, text: "Test description")
    end

    it { should validate_uniqueness_of(:picture_id).scoped_to(:language_id) }
  end
end
