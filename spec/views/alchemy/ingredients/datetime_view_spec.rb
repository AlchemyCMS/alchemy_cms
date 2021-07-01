# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_essence_date_view" do
  let(:ingredient) { Alchemy::Ingredients::Datetime.new(value: "2013-10-27 21:14:16 +0100") }
  let(:options) { {} }

  before do
    allow(view).to receive(:options).and_return(options)
  end

  context "with date value" do
    context "without date_format passed" do
      it "translates the date value with default format" do
        render ingredient
        expect(rendered).to have_content("Sun, 27 Oct 2013 20:14:16 +0000")
      end
    end

    context "with option date_format set to rfc822" do
      let(:options) { { date_format: "rfc822" } }

      it "renders the date rfc822 conform" do
        render ingredient
        expect(rendered).to have_content("Sun, 27 Oct 2013 20:14:16 +0000")
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
