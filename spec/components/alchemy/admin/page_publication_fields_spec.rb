# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PagePublicationFields, type: :component do
  let(:alchemy_page) { build_stubbed(:alchemy_page) }
  let(:component) { described_class.new(page: alchemy_page) }

  it "wraps the fields in a custom element" do
    render_inline component
    expect(page).to have_css("alchemy-page-publication-fields")
  end

  describe "public checkbox" do
    it "renders a public checkbox label" do
      render_inline component
      expect(page).to have_css("label.checkbox", text: Alchemy::Page.human_attribute_name(:public))
      expect(page).to have_css("input[type='checkbox']")
    end

    context "when the page is not public" do
      it "is not checked" do
        render_inline component
        expect(page).not_to have_css("input[type='checkbox'][checked]")
      end
    end

    context "when the page is public" do
      before { allow(alchemy_page).to receive(:public?) { true } }

      it "is checked" do
        render_inline component
        expect(page).to have_css("input[type='checkbox'][checked]")
      end
    end

    context "when the page is scheduled" do
      before { allow(alchemy_page).to receive(:scheduled?) { true } }

      it "is checked" do
        render_inline component
        expect(page).to have_css("input[type='checkbox'][checked]")
      end
    end

    context "when public_on is a fixed attribute" do
      before do
        allow(alchemy_page).to receive(:attribute_fixed?) { false }
        allow(alchemy_page).to receive(:attribute_fixed?).with(:public_on) { true }
      end

      it "disables the checkbox" do
        render_inline component
        expect(page).to have_css("input[type='checkbox'][disabled]")
      end

      it "renders a hint tooltip" do
        render_inline component
        tooltip = page.find("sl-tooltip.like-hint-tooltip")
        expect(tooltip[:content]).to eq(Alchemy.t(:attribute_fixed))
      end
    end
  end

  describe "publication date fields" do
    it "renders public_on and public_until fields" do
      render_inline component
      expect(page).to have_css("input[name='page[public_on]'][type='datetime-local']")
      expect(page).to have_css("input[name='page[public_until]'][type='datetime-local']")
    end

    context "without any publication dates" do
      it "hides the date fields" do
        render_inline component
        expect(page).to have_css(".page-publication-date-fields.hidden")
      end
    end

    context "with a public_on date" do
      before { allow(alchemy_page).to receive(:public_on) { Time.current } }

      it "shows the date fields" do
        render_inline component
        expect(page).to have_css(".page-publication-date-fields")
        expect(page).not_to have_css(".page-publication-date-fields.hidden")
      end
    end

    context "when public_on is a fixed attribute" do
      before do
        allow(alchemy_page).to receive(:attribute_fixed?) { false }
        allow(alchemy_page).to receive(:attribute_fixed?).with(:public_on) { true }
      end

      it "disables the public_on field" do
        render_inline component
        expect(page).to have_css("input[name='page[public_on]'][disabled]")
      end
    end

    context "when public_until is a fixed attribute" do
      before do
        allow(alchemy_page).to receive(:attribute_fixed?) { false }
        allow(alchemy_page).to receive(:attribute_fixed?).with(:public_until) { true }
      end

      it "disables the public_until field" do
        render_inline component
        expect(page).to have_css("input[name='page[public_until]'][disabled]")
      end
    end
  end
end
