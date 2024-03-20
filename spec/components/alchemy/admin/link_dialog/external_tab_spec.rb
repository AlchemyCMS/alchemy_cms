# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::ExternalTab, type: :component do
  let(:url) { "https://guides.alchemy-cms.com" }
  let(:is_selected) { false }
  let(:link_title) { "foo" }
  let(:link_target) { nil }

  before do
    render_inline(described_class.new(url, is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :external, "External"
  it_behaves_like "a link dialog - target select", :external

  context "tab not selected" do
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=external_link]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:is_selected) { true }

    it "should have the value of the url" do
      expect(page.find(:css, "input[name=external_link]").value).to eq(url)
    end
  end
end
