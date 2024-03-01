# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Pages::AnchorTab, type: :component do
  let(:alchemy_page) { create(:alchemy_page) }
  let(:url) { fragment }
  let(:fragment) { "bar" }
  let(:selected_tab) { :foo }

  before do
    render_inline(described_class.new(url, selected_tab, nil, nil))
  end

  context "tab not selected" do
    it "should not have the value of the fragment" do
      expect(page.find(:css, "select[name=anchor_link]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:selected_tab) { :anchor }
    it "should have the value of the fragment" do
      expect(page.find(:css, "select[name=anchor_link]").value).to eq(fragment)
    end
  end
end
