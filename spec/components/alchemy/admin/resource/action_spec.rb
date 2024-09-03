# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::Action, type: :component do
  let(:name) { nil }
  let(:tooltip) { nil }
  let(:block) { lambda { |item| "Foo" } }
  let(:custom_resource) { Struct.new(:name, :description) }
  let(:resource) { custom_resource.new("Foo", "Bar") }
  let(:component) { described_class.new(name, tooltip, &block) }

  subject(:render) do
    with_controller_class(Admin::EventsController) do
      render_inline(component.with_resource(resource))
    end
  end

  it "should render element" do
    render
    expect(page).to have_text("Foo")
  end

  it "should not render a tooltip" do
    render
    expect(page).to_not have_selector("sl-tooltip")
  end

  context "with name" do
    let(:name) { :edit }

    it "should evaluate name with CanCanCan" do
      expect(component).to receive(:can?).with(name, resource) { true }
      render
      expect(page).to have_text("Foo")
    end

    it "should show nothing, if the user does not have access" do
      expect(component).to receive(:can?) { false }
      render
      expect(page).to_not have_text("Foo")
    end
  end

  context "with tooltip" do
    let(:tooltip) { "Bar" }

    it "should render a tooltip" do
      render
      expect(page).to have_css('sl-tooltip[content="Bar"]', text: "Foo")
    end
  end
end
