# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PreviewTimeSelect, type: :component do
  let(:page_version) { create(:alchemy_page_version) }
  let(:url) { "/admin/pages/1/edit" }
  let(:component) { described_class.new(page_version, url:, selected:) }
  let(:selected) { nil }

  describe "disabled state" do
    context "with no future scheduled elements" do
      before do
        create(:alchemy_element, page_version:, public_on: 1.day.ago)
      end

      it "disables the select" do
        render_inline component
        expect(page).to have_css("select[disabled]")
      end
    end

    context "with future scheduled elements" do
      before do
        create(:alchemy_element, page_version:, public_on: 1.day.from_now)
      end

      it "enables the select" do
        render_inline component
        expect(page).not_to have_css("select[disabled]")
      end
    end
  end

  describe "preview_times" do
    it "includes future public_on dates" do
      future_time = 2.days.from_now.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: future_time)

      render_inline component
      expect(page).to have_css("option[value='#{future_time.iso8601}']")
    end

    it "includes future public_until dates" do
      future_time = 3.days.from_now.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: 1.day.ago, public_until: future_time)

      render_inline component
      expect(page).to have_css("option[value='#{future_time.iso8601}']")
    end

    it "excludes past public_on dates" do
      past_time = 1.day.ago.change(usec: 0)
      future_time = 1.day.from_now.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: past_time, public_until: future_time)

      render_inline component
      expect(page).not_to have_css("option[value='#{past_time.iso8601}']")
    end

    it "excludes past public_until dates" do
      past_time = 1.hour.ago.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: 2.days.ago, public_until: past_time)

      # Need another future element so the component renders
      create(:alchemy_element, page_version:, public_on: 1.day.from_now)

      render_inline component
      expect(page).not_to have_css("option[value='#{past_time.iso8601}']")
    end

    it "deduplicates identical timestamps" do
      future_time = 2.days.from_now.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: future_time)
      create(:alchemy_element, page_version:, public_on: future_time)

      render_inline component
      expect(page).to have_css("option[value='#{future_time.iso8601}']", count: 1)
    end

    it "sorts times chronologically" do
      later = 3.days.from_now.change(usec: 0)
      earlier = 1.day.from_now.change(usec: 0)
      create(:alchemy_element, page_version:, public_on: later)
      create(:alchemy_element, page_version:, public_on: earlier)

      render_inline component
      values = page.all("select option:not([value=''])").map { |o| o[:value] }
      expect(values).to eq([earlier.iso8601, later.iso8601])
    end
  end

  describe "selected option" do
    let(:future_time) { 2.days.from_now.change(usec: 0) }
    let(:selected) { future_time.iso8601 }

    before do
      create(:alchemy_element, page_version:, public_on: future_time)
    end

    it "marks the matching option as selected" do
      render_inline component
      expect(page).to have_css("option[selected][value='#{future_time.iso8601}']")
    end
  end

  describe "form" do
    before do
      create(:alchemy_element, page_version:, public_on: 1.day.from_now)
    end

    it "submits to the given url" do
      render_inline component
      expect(page).to have_css("form[action='#{url}'][method='get']")
    end

    it "has a blank option for Now" do
      render_inline component
      expect(page).to have_css("option[value='']", text: "Now")
    end
  end
end
