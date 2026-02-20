# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::DatetimeView, type: :component do
  around do |example|
    time_zone = Rails.application.config.time_zone
    Rails.application.config.time_zone = "Berlin"
    example.run
    Rails.application.config.time_zone = time_zone
  end

  let(:ingredient) do
    Alchemy::Ingredients::Datetime.new(value: "2024-08-29T10:00:00.000Z")
  end

  let(:options) { {} }

  subject do
    render_inline described_class.new(ingredient, **options)
    page
  end

  context "with date value" do
    context "without date_format passed" do
      it "translates the date value with default format" do
        is_expected.to have_content("29-08-2024 12:00pm")
      end
    end

    context "with date_format in settings" do
      before do
        allow(ingredient).to receive(:settings) do
          {date_format: "%d.%m."}
        end
      end

      it "translates the date value with format from settings" do
        is_expected.to have_content("29.08.")
      end

      context "but with format passed as argument" do
        let(:options) { {date_format: "%d.%m.%Y"} }

        it "translates the date value with format from arguments" do
          is_expected.to have_content("29.08.2024")
        end
      end
    end

    context "with option date_format set to rfc822" do
      let(:options) { {date_format: "rfc822"} }

      it "renders the date rfc822 conform" do
        is_expected.to have_content("Thu, 29 Aug 2024 12:00:00 +0200")
      end
    end
  end

  context "with blank date value" do
    let(:ingredient) { Alchemy::Ingredients::Datetime.new(value: nil) }

    it "renders nothing" do
      is_expected.to have_content("")
    end
  end
end
