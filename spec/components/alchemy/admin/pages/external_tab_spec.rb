# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Pages::ExternalTab, type: :component do
  let(:url) { "https://guides.alchemy-cms.com" }
  let(:selected_tab) { :foo }

  before do
    render_inline(described_class.new(url, selected_tab, nil, nil))
  end

  context "tab not selected" do
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=external_link]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:selected_tab) { :external }
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=external_link]").value).to eq(url)
    end
  end
end
