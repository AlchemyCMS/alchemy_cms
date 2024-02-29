# frozen_string_literal: true

require "rails_helper"

class TestTab < Alchemy::Admin::Pages::BaseLinkTab
  delegate :render_message, to: :helpers

  def title
    "Test Tab"
  end

  def type
    :test
  end

  def fields
    [
      title_input,
      target_select
    ]
  end
end

RSpec.describe Alchemy::Admin::Pages::BaseLinkTab, type: :component do
  before do
    render_inline(TestTab.new("/foo"))
  end

  it "should render a tab with a panel" do
    expect(page).to have_selector("sl-tab[panel='overlay_tab_test_link']")
    expect(page).to have_selector("sl-tab-panel[name='overlay_tab_test_link']")
  end

  it "should have a title" do
    expect(page).to have_text("Test Tab")
  end

  it "should allow to add title input" do
    expect(page).to have_selector("input[name=test_link_title]")
  end

  it "should allow to add target select" do
    expect(page).to have_selector("select[name=test_link_target]")
  end
end
