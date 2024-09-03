# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::Cell, type: :component do
  let(:css_classes) { "foo bar" }
  let(:block) { lambda { |item| "Foo" } }
  let(:custom_resource) { Struct.new(:name, :description) }
  let(:resource) { custom_resource.new("Foo", "Bar") }
  let(:component) { described_class.new(css_classes, &block) }

  subject(:render) do
    with_controller_class(Admin::EventsController) do
      render_inline(component.with_resource(resource))
    end
  end

  it "should render element" do
    render
    expect(page).to have_text("Foo")
  end

  it "should have the css classes" do
    render
    expect(page).to have_selector("td.foo")
    expect(page).to have_selector("td.bar", text: "Foo")
  end

  context "with another block" do
    let(:block) { lambda { |item| item.description } }

    it "should use the resource" do
      render
      expect(page).to have_text("Bar")
    end
  end
end
