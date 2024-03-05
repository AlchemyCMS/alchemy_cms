# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::AnchorTab, type: :component do
  before do
    render_inline(described_class.new)
  end

  it "should have an anchor select" do
    expect(page).to have_selector("select[name=anchor_link] option")
  end

  it "should have a title input" do
    expect(page).to have_selector("input[name=anchor_link_title]")
  end
end
