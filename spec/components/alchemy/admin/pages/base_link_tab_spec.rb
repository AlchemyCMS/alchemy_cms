# frozen_string_literal: true

require "rails_helper"

class TestTab < Alchemy::Admin::Pages::BaseLinkTab
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
  let(:active_tab) { "foo" }
  let(:title) { nil }
  let(:target) { nil }

  before do
    render_inline(TestTab.new("/foo", active_tab, title, target))
  end

  context "default configuration" do
    it "should render a tab with a panel" do
      expect(page).to have_selector("sl-tab[panel='overlay_tab_test_link']")
      expect(page).to have_selector("sl-tab-panel[name='overlay_tab_test_link']")
    end

    it "should have a title" do
      expect(page).to have_text("Test Tab")
    end

    it "should allow to add title input and have no value" do
      expect(page).to have_selector("input[name=test_link_title]")
      expect(page.find(:css, "input[name=test_link_title]").value).to be_nil
    end

    it "should allow to add target select" do
      expect(page).to have_selector("select[name=test_link_target]")
      expect(page.find(:css, "select[name=test_link_target]").value).to be_empty
    end

    it "isn't active" do
      expect(page).to_not have_selector("sl-tab[active]")
    end
  end

  context "active tab" do
    let(:active_tab) { "test" }

    it "is active" do
      expect(page).to have_selector("sl-tab[active]")
    end
  end

  context "title input" do
    let(:title) { "test" }

    it "should have a pre-filled value" do
      expect(page.find(:css, "input[name=test_link_title]").value).to eq(title)
    end
  end

  context "target select" do
    let(:target) { "blank" }

    it "should have a pre-filled value" do
      expect(page.find(:css, "select[name=test_link_target]").value).to eq(target)
    end
  end
end
