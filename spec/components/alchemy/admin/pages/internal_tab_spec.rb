# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Pages::InternalTab, type: :component do
  let(:alchemy_page) { create(:alchemy_page) }
  let(:url) { alchemy_page.url_path }
  let(:selected_tab) { :foo }

  before do
    render_inline(described_class.new(url, selected_tab, nil, nil))
  end

  context "tab not selected" do
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=internal_link]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:selected_tab) { :internal }
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=internal_link]").value).to eq(url)
    end
  end
end
