# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::Tabs, type: :component do
  let(:selected_tab) { "internal" }

  before do
    render_inline(described_class.new(selected_tab: selected_tab))
  end

  it "render a tab structure" do
    expect(page).to have_selector("sl-tab-group > sl-tab")
    expect(page).to have_selector("sl-tab-group > sl-tab-panel")
  end

  it "renders all four tabs" do
    expect(page).to have_selector("sl-tab[panel='overlay_tab_anchor_link']")
    expect(page).to have_selector("sl-tab[panel='overlay_tab_file_link']")
    expect(page).to have_selector("sl-tab[panel='overlay_tab_internal_link']")
    expect(page).to have_selector("sl-tab[panel='overlay_tab_external_link']")
  end

  it "marks the internal tab as selected" do
    expect(page).to have_selector("sl-tab[panel='overlay_tab_internal_link'][active]")
  end

  context "without a selected tab" do
    let(:selected_tab) { nil }

    it "marks the external tab as selected" do
      expect(page).not_to have_selector("sl-tab[panel='overlay_tab_internal_link'][active]")
    end
  end

  context "change selected tab" do
    let(:selected_tab) { "external" }

    it "marks the external tab as selected" do
      expect(page).to have_selector("sl-tab[panel='overlay_tab_external_link'][active]")
    end
  end
end
