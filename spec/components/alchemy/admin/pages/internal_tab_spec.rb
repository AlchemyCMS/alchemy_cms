# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Pages::InternalTab, type: :component do
  let(:alchemy_page) { create(:alchemy_page) }
  let(:url) { alchemy_page.url_path + "#" + fragment }
  let(:fragment) { "bar" }
  let(:selected_tab) { :foo }

  before do
    render_inline(described_class.new(url, selected_tab, nil, nil))
  end

  context "tab not selected" do
    it "should not have the value of the url" do
      expect(page.find(:css, "input[name=internal_link]").value).to be_empty
    end

    it "should not have the value of the hash fragment" do
      expect(page.find(:css, "select[name=element_anchor]").value).to be_empty
    end
  end

  context "tab selected" do
    let(:selected_tab) { :internal }
    it "should have the value of the url" do
      expect(page.find(:css, "input[name=internal_link]").value).to eq(url)
    end

    it "should not have the value of the hash fragment" do
      expect(page.find(:css, "select[name=element_anchor]").value).to eq(fragment)
    end
  end
end
