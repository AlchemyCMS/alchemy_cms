# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::Header, type: :component do
  let(:name) { :name }
  let(:query) { nil }
  let(:label) { nil }
  let(:type) { :string }
  let(:sortable) { false }
  let(:css_classes) { "foo bar" }

  let(:component) { described_class.new(name, query, label: label, type: type, sortable: sortable, css_classes: css_classes) }

  subject(:render) do
    with_controller_class(Admin::EventsController) do
      render_inline(component)
    end
  end

  it "should render header" do
    render
    expect(page).to have_selector("th", text: "name")
  end

  it "should the css classes" do
    render
    expect(page).to have_selector("th.foo")
    expect(page).to have_selector("th.bar")
  end

  context "with label" do
    let(:label) { "Foo" }

    it "should render header" do
      render
      expect(page).to have_selector("th", text: "Foo")
    end
  end

  context "with sortable" do
    let(:sortable) { true }
    let(:query) { Event.ransack({}) }

    it "should render a sortable link" do
      expect(component).to receive(:sort_link).with(query, :name, :name, {default_order: "asc"})
      render
    end

    context "with date - type" do
      let(:name) { :created_at }
      let(:type) { :datetime }

      it "should render a sortable link with desc - order" do
        expect(component).to receive(:sort_link).with(query, :created_at, :created_at, {default_order: "desc"})
        render
      end
    end
  end
end
