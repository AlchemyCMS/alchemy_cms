# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ResourceTable, type: :component do
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
        render_inline(described_class.new(collection)) do |component|
          component.add_column(:name)
          component.add_column(:description)
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
          component.add_column(:name, label: "Awesome Name")
        end
      end

      it "renders a table header with custom label" do
        expect(page).to have_selector("table th", text: "Awesome Name")
      end
    end

    context "columns with a custom block" do
      subject(:render) do
        render_inline(described_class.new(collection)) do |component|
          component.add_column(:description) { |item| item[:description].truncate(10) }
        end
      end

      it "renders a table cell with a custom block" do
        expect(page).to have_selector("table td", text: "Awesome...")
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
