# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::InternalTab, type: :component do
  let(:alchemy_page) { create(:alchemy_page) }
  let(:url) { alchemy_page.url_path + "#" + fragment }
  let(:fragment) { "bar" }

  let(:is_selected) { false }
  let(:link_title) { nil }
  let(:link_target) { nil }

  before do
    render_inline(described_class.new(url, is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :internal, "Internal"
  it_behaves_like "a link dialog - target select", :internal

  context "link field" do
    context "tab not selected" do
      it "should not have the value of the url" do
        expect(page.find(:css, "input[name=internal_link]").value).to be_empty
      end

      it "should not have the value of the hash fragment" do
        expect(page.find(:css, "input[name=element_anchor]").value).to be_empty
      end
    end

    context "tab selected" do
      let(:is_selected) { true }

      it "should have the value of the url" do
        expect(page.find(:css, "input[name=internal_link]").value).to eq(url)
      end

      it "should not have the value of the hash fragment" do
        expect(page.find(:css, "input[name=element_anchor]").value).to eq(fragment)
      end
    end
  end
end
