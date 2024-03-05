# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::InternalTab, type: :component do
  before do
    render_inline(described_class.new)
  end

  it "should have an url input" do
    expect(page).to have_selector("input[name=internal_link]")
  end

  it "should have a dom id select" do
    expect(page).to have_selector("input[name=element_anchor]")
  end

  it "should have a title input" do
    expect(page).to have_selector("input[name=internal_link_title]")
  end

  it "should have a target select" do
    expect(page).to have_selector("select[name=internal_link_target]")
  end
end
