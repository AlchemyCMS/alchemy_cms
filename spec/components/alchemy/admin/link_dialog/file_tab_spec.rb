# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::FileTab, type: :component do
  let!(:attachment) { create(:alchemy_attachment) }
  let(:url) { Alchemy::Engine.routes.url_helpers.download_attachment_path(id: attachment.id, name: attachment.slug) }

  before do
    render_inline(described_class.new("/foo"))
  end

  it "should render a pre-filled file select" do
    expect(page.find(:css, "select[name=file_link] option:last-child").value).to eq(url)
  end

  it "should have a title input" do
    expect(page).to have_selector("input[name=file_link_title]")
  end

  it "should have a target select" do
    expect(page).to have_selector("select[name=file_link_target]")
  end
end
