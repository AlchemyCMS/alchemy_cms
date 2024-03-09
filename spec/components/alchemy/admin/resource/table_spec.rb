# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::Table, type: :component do
  let(:collection) { [] }
  before do
    render
  end

  subject(:render) do
    render_inline(described_class.new(collection))
  end

  context "with data" do
    let(:collection) {
      [
        {name: "Foo", description: "Awesome description"},
        {name: "Bar", description: "Another description"}
      ]
    }

    it "doesn't renders an info message" do
      expect(page).to_not have_content("Nothing found")
    end

    context "columns without block" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |table|
          table.column(:name)
          table.column(:description)
        end
      end

      it "renders a table header" do
        expect(page).to have_selector("table th", text: "name")
        expect(page).to have_selector("table th", text: "description")
      end

      it "renders a table cell" do
        expect(page).to have_selector("table td.name", text: "Foo")
        expect(page).to have_selector("table td.description", text: "Awesome description")
      end
    end

    context "columns with custom label" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |component|
          component.column(:name, label: "Awesome Name")
        end
      end

      it "renders a table header with custom label" do
        expect(page).to have_selector("table th", text: "Awesome Name")
      end
    end

    context "columns with a custom block" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |table|
          table.column(:description) { |item| item[:description].truncate(10) }
        end
      end

      it "renders a table cell with a custom block" do
        expect(page).to have_selector("table td", text: "Awesome...")
      end
    end

    context "icon column with variable" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |table|
          table.icon_column(:home)
        end
      end

      it "renders a table cell with a home icon" do
        expect(page).to have_selector("table td alchemy-icon[name='home']")
      end
    end

    context "icon column with custom block" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |table|
          table.icon_column { |row| (row[:name] == "Foo") ? :save : :home }
        end
      end

      it "renders a table cell with a home icon another one with a save icon" do
        expect(page).to have_selector("table td alchemy-icon[name='save']")
        expect(page).to have_selector("table td alchemy-icon[name='home']")
      end
    end

    context "actions" do
      let(:name) { nil }
      let(:tooltip) { nil }

      subject(:render) do
        render_inline(described_class.new(collection)) do |table|
          table.action(name, tooltip: tooltip) { |row| "Foo" }
        end
      end

      context "action without any config" do
        it "renders an action entry" do
          expect(page).to have_selector("table td.tools", text: "Foo")
        end

        it "does not render a tooltip without tooltip config" do
          expect(page).to_not have_selector("table td.tools sl-tooltip")
        end
      end

      context "with tooltip" do
        let(:tooltip) { "Bar" }

        it "does render a tooltip without tooltip config" do
          expect(page).to have_selector("table td.tools sl-tooltip[content='Bar']")
        end
      end

      context "with permission" do
        let(:name) { :unknown_permission }

        it "does not renders an action entry" do
          expect(page).to_not have_selector("table td.tools", text: "Foo")
        end
      end
    end
  end

  context "without any data" do
    it "renders an info message" do
      expect(page).to have_content("Nothing found")
    end

    context "with another nothing found - label" do
      subject(:render) do
        render_inline(described_class.new(collection, nothing_found_label: "No user found"))
      end

      it "renders an info message" do
        expect(page).to have_content("No user found")
      end
    end
  end
end
