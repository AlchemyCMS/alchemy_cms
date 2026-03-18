# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::TimezoneSelect, type: :component do
  subject! do
    allow(vc_test_view_context).to receive(:url_for) { "/admin/dashboard" }
    render_inline described_class.new
  end

  it "renders an sl-dropdown with an icon trigger" do
    expect(page).to have_selector("sl-dropdown sl-button[slot='trigger'] alchemy-icon[name='time-zone']")
  end

  it "renders a select with timezone options" do
    expect(page).to have_selector("select[name='admin_timezone']")
  end

  it "includes all ActiveSupport timezones" do
    expect(page).to have_selector("select[name='admin_timezone'] option", minimum: 100)
  end

  it "pre-selects the current timezone" do
    expect(page).to have_selector(
      "select[name='admin_timezone'] option[selected][value='#{Time.zone.name}']"
    )
  end
end
