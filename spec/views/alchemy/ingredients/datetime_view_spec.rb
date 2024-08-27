# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_datetime_view" do
  let(:ingredient) { Alchemy::Ingredients::Datetime.new(value: "2013-10-27 21:14:16 +0100") }
  let(:options) { {} }

  context "with date value" do
    context "without date_format passed" do
      it "translates the date value with default format" do
        render ingredient, options: options
        expect(rendered).to have_content("10.27.2013 21:14")
      end
    end

    context "with option date_format set to rfc822" do
      let(:options) { {date_format: "rfc822"} }

      it "renders the date rfc822 conform" do
        render ingredient, options: options
        expect(rendered).to have_content("Sun, 27 Oct 2013 21:14:16 +0100")
      end
    end
  end

  context "with blank date value" do
    let(:ingredient) { Alchemy::Ingredients::Datetime.new(value: nil) }

    it "renders nothing" do
      render ingredient, options: options
      expect(rendered).to eq("")
    end
  end
end
