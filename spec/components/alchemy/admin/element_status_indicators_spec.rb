# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementStatusIndicators, type: :component do
  before { render_inline(described_class.new(element: element)) }

  context "when the element is hidden" do
    let(:element) { build_stubbed(:alchemy_element, public_on: nil, public_until: nil) }

    it "renders the hidden indicator" do
      expect(page).to have_selector("alchemy-icon[name='cloud-off']")
      expect(page).to have_selector(".element-hidden-label")
    end

    it "keeps the scheduled indicator hidden" do
      expect(page).to have_selector(".element-scheduled-icon[hidden]")
    end
  end

  context "when the element is scheduled" do
    let(:element) { build_stubbed(:alchemy_element, public_on: 1.day.from_now, public_until: nil) }

    it "shows the scheduled indicator" do
      expect(page).to have_selector("alchemy-icon[name='calendar-schedule']")
      expect(page).to have_no_selector(".element-scheduled-icon[hidden]")
    end

    it "does not render the hidden indicator" do
      expect(page).to have_no_selector("alchemy-icon[name='cloud-off']")
    end
  end

  context "when the element is currently public" do
    let(:element) { build_stubbed(:alchemy_element, public_on: 1.day.ago, public_until: nil) }

    it "renders neither the hidden badge nor a visible scheduled badge" do
      expect(page).to have_no_selector("alchemy-icon[name='cloud-off']")
      expect(page).to have_selector(".element-scheduled-icon[hidden]")
    end
  end
end
