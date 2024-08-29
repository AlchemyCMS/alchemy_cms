# frozen_string_literal: true

require "rails_helper"

CustomResource = Struct.new(:name, :description)

RSpec.describe Alchemy::Admin::Resource::Table, type: :component do
  let(:collection) { [] }
  let(:component) { described_class.new(collection) }

  subject(:render) do
    with_controller_class(Admin::EventsController) do
      render_inline(component)
    end
  end

  context "with data" do
    let(:collection) {
      [
        CustomResource.new("Foo", "Awesome description"),
        CustomResource.new("Bar", "Another description")
      ]
    }

    context "columns without block" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.column(:name)
            table.column(:description)
          end
        end
      end

      before do
        render
      end

      it "renders a table header" do
        expect(page).to have_selector("table th", text: "Name")
        expect(page).to have_selector("table th", text: "Description")
      end

      it "renders a table cell" do
        expect(page).to have_selector("table td.name", text: "Foo")
        expect(page).to have_selector("table td.description", text: "Awesome description")
      end
    end

    context "columns with custom header" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |component|
            component.column(:name, header: "Awesome Name")
          end
        end
      end

      it "renders a table header with custom header" do
        render
        expect(page).to have_selector("table th", text: "Awesome Name")
      end
    end

    context "columns with a custom block" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.column(:description) { |item| item[:description].truncate(10) }
          end
        end
      end

      it "renders a table cell with a custom block" do
        render
        expect(page).to have_selector("table td", text: "Awesome...")
      end
    end

    context "columns with a custom block" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.column(:description, class_name: "fooooo")
          end
        end
      end

      it "renders a table cell with given class" do
        render
        expect(page).to have_selector("table td.fooooo")
      end
    end

    context "icon column with variable" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.icon_column(:home)
          end
        end
      end

      it "renders a table cell with a home icon" do
        render
        expect(page).to have_selector("table td alchemy-icon[name='home']")
      end
    end

    context "icon column with custom block" do
      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.icon_column { |row| (row[:name] == "Foo") ? :save : :home }
          end
        end
      end

      it "renders a table cell with a home icon another one with a save icon" do
        render
        expect(page).to have_selector("table td alchemy-icon[name='save']")
        expect(page).to have_selector("table td alchemy-icon[name='home']")
      end
    end

    context "actions" do
      let(:name) { nil }
      let(:tooltip) { nil }

      subject(:render) do
        with_controller_class(Admin::EventsController) do
          render_inline(component) do |table|
            table.column(:name)
            table.with_action(name, tooltip) { |row| "Foo" }
          end
        end
      end

      before do
        render
      end

      context "button without any config" do
        it "renders an button entry" do
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

        it "does not renders a button entry" do
          expect(page).to_not have_selector("table td.tools", text: "Foo")
        end
      end
    end
  end

  context "without any data" do
    before do
      render
    end

    it "renders an info message" do
      expect(page).to have_content("Nothing found")
    end

    context "with another nothing found - label" do
      let(:component) { described_class.new(collection, nothing_found_label: "No user found") }

      it "renders an info message" do
        expect(page).to have_content("No user found")
      end
    end
  end
end
