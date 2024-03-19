# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::ExternalTab, type: :component do
  before do
    render_inline(described_class.new("/foo"))
  end

  it "should have an url input" do
    expect(page).to have_selector("input[name=external_link]")
  end

  it "should have a title input" do
    expect(page).to have_selector("input[name=external_link_title]")
  end

  it "should have a target select" do
    expect(page).to have_selector("select[name=external_link_target]")
  end
end
