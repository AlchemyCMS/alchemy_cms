# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::AnchorTab, type: :component do
  let(:is_selected) { false }
  let(:link_title) { nil }
  let(:link_target) { nil }

  before do
    render_inline(described_class.new("foo", is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :anchor, "Anchor"

  context "tab not selected" do
    it "should not have the value of the fragment" do
      expect(page.find(:css, "select[name=anchor_link]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:is_selected) { true }
    it "should have the value of the fragment" do
      expect(page.find(:css, "select[name=anchor_link]").value).to eq("foo")
    end
  end
end
