# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/elements/_element" do
  before do
    allow(element).to receive(:definition) { definition }
  end

  let(:definition) do
    {
      name: "with_message",
      message: "One nice message",
    }.with_indifferent_access
  end

  subject do
    render Alchemy::ElementEditor.new(element)
    rendered
  end

  context "with message given in element definition" do
    let(:element) { create(:alchemy_element, name: "with_message") }

    it "renders the message" do
      is_expected.to have_css('.message:contains("One nice message")')
    end

    context "that contains HTML" do
      let(:definition) do
        {
          name: "with_message",
          message: "<h1>One nice message</h1>",
        }.with_indifferent_access
      end

      it "renders the HTML message" do
        is_expected.to have_css('.message h1:contains("One nice message")')
      end
    end
  end

  context "with warning given in element definition" do
    let(:element) { create(:alchemy_element, name: "with_warning") }

    let(:definition) do
      {
        name: "with_warning",
        warning: "One nice warning",
      }.with_indifferent_access
    end

    it "renders the warning" do
      is_expected.to have_css('.warning:contains("One nice warning")')
    end

    context "that contains HTML" do
      let(:definition) do
        {
          name: "with_warning",
          warning: "<h1>One nice warning</h1>",
        }.with_indifferent_access
      end

      it "renders the HTML warning" do
        is_expected.to have_css('.warning h1:contains("One nice warning")')
      end
    end
  end
end
