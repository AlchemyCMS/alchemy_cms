require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::CheckboxFilter, type: :component do
  let(:name) { "published" }
  let(:label) { "Published" }
  let(:params) { {q: {published: true}.with_indifferent_access} }

  let(:component) { described_class.new(name:, label:, params:) }

  before do
    render
  end

  subject(:render) do
    render_inline component
  end

  it "renders a checkbox input" do
    expect(page).to have_selector('input[type="checkbox"][name="q[published]"][form="resource_search"]')
  end

  it "renders the correct label" do
    expect(page).to have_selector("label", text: "Published")
  end
end
