# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::FileView, type: :component do
  let(:attachment) do
    create(:alchemy_attachment)
  end

  let(:ingredient) { Alchemy::Ingredients::File.new(attachment: attachment) }
  let(:options) { {} }
  let(:html_options) { {} }

  subject do
    render_inline described_class.new(
      ingredient,
      **options,
      html_options: html_options
    )
    page
  end

  context "without attachment" do
    let(:ingredient) { Alchemy::Ingredients::File.new(attachment: nil) }

    it "renders nothing" do
      is_expected.to have_content("")
    end
  end

  context "with attachment" do
    it "renders a link to download the attachment" do
      is_expected.to have_selector(
        "a[href='/attachment/#{attachment.id}/download/#{attachment.slug}.#{attachment.suffix}']"
      )
    end

    context "with no link_text set" do
      it "has this attachments name as link text" do
        is_expected.to have_selector("a:contains('#{attachment.name}')")
      end
    end

    context "with link_text set in the local options" do
      let(:options) do
        {link_text: "Download this file"}
      end

      it "has this value as link text" do
        is_expected.to have_selector("a:contains('Download this file')")
      end
    end

    context "with link_text set in the ingredient settings" do
      before do
        allow(ingredient).to receive(:settings) { {link_text: "Download this file"} }
      end

      it "has this value as link text" do
        is_expected.to have_selector("a:contains('Download this file')")
      end
    end

    context "with link_text stored in the ingredient attribute" do
      before do
        allow(ingredient).to receive(:link_text) { "Download this file" }
      end

      it "has this value as link text" do
        is_expected.to have_selector("a:contains('Download this file')")
      end
    end

    context "with html_options given" do
      let(:html_options) do
        {title: "Bar", class: "blue"}
      end

      it "renders the linked ingredient with these options" do
        is_expected.to have_selector('a.blue[title="Bar"]')
      end
    end
  end

  context "with css_class set" do
    before do
      allow(ingredient).to receive(:css_class) { "file-download" }
    end

    it "has this class at the link" do
      is_expected.to have_selector("a.file-download")
    end
  end
end
