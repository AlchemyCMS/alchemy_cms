# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::AppliedFilter, type: :component do
  let(:link) { "/admin/pages" }
  let(:label) { "Published" }
  let(:component) { described_class.new(label:, link:) }

  subject(:render) do
    render_inline(component)
  end

  it "should render element" do
    render
    expect(page).to have_css(".applied-filter")
    expect(page).to have_text("Published")
    expect(page).to have_css("a[href='/admin/pages']")
  end
end
