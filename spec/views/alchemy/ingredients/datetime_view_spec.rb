# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_datetime_view" do
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

  before do
    allow(view).to receive(:options).and_return(options)
  end

  context "with date value" do
    context "without date_format passed" do
      it "translates the date value with default format" do
        render ingredient, options: options
        expect(rendered).to have_content("Thu, 29 Aug 2024 12:00:00 +0200")
      end
    end

    context "with option date_format set to rfc822" do
      let(:options) { {date_format: "rfc822"} }

      it "renders the date rfc822 conform" do
        render ingredient, options: options
        expect(rendered).to have_content("Thu, 29 Aug 2024 12:00:00 +0200")
      end
    end
  end

  context "with blank date value" do
    let(:ingredient) { Alchemy::Ingredients::Datetime.new(value: nil) }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end
end
