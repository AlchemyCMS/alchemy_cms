# frozen_string_literal: true

require "rails_helper"

class BaseTestTab < Alchemy::Admin::LinkDialog::BaseTab
  delegate :render_message, to: :helpers

  def title
    "Base Test Tab"
  end

  def name
    :base_test
  end

  def fields
    [
      title_input,
      target_select
    ]
  end
end

RSpec.describe Alchemy::Admin::LinkDialog::BaseTab, type: :component do
  before do
    render_inline(BaseTestTab.new("/foo"))
  end

  it "should render a tab with a panel" do
    expect(page).to have_selector("sl-tab[panel='overlay_tab_base_test_link']")
    expect(page).to have_selector("sl-tab-panel[name='overlay_tab_base_test_link']")
  end

  it "should have a title" do
    expect(page).to have_text("Base Test Tab")
  end

  it "should allow to add title input" do
    expect(page).to have_selector("input[name=base_test_link_title]")
  end

  it "should allow to add target select" do
    expect(page).to have_selector("select[name=base_test_link_target]")
  end
end
