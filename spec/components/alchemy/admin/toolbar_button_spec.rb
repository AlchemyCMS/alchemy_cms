require "rails_helper"

RSpec.describe Alchemy::Admin::ToolbarButton, type: :component do
  before do
    allow_any_instance_of(described_class).to receive(:render_icon) do |component|
      Alchemy::Admin::Icon.new(component.icon, style: component.icon_style).call
    end
  end

  let(:component) do
    described_class.new(url: admin_dashboard_path, icon: "info", label: "Show Info")
  end

  context "with permission" do
    before { expect(component).to receive(:can?) { true } }

    it "renders a toolbar button" do
      render_inline component
      expect(page).to have_css %(sl-tooltip a.icon_button[href="#{admin_dashboard_path}"])
    end

    context "with id option set" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          id: "my-button"
        )
      end

      it "renders a normal link" do
        render_inline component
        expect(page).to have_css("#my-button.toolbar_button")
      end
    end

    context "with dialog option set to false" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          dialog: false
        )
      end

      it "renders a normal link" do
        render_inline component
        expect(page).to have_css(%(a[href="#{admin_dashboard_path}"]))
        expect(page).not_to have_css("[data-dialog-options]")
      end
    end

    context "with dialog_options set" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          dialog_options: {
            title: "Info",
            size: "300x200"
          }
        )
      end

      it "passes them to the link" do
        render_inline component
        expect(page).to have_css(%(a[data-dialog-options='{"title":"Info","size":"300x200"}']))
      end
    end

    context "with hotkey set" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          hotkey: "alt+i"
        )
      end

      it "passes it to the link" do
        render_inline component
        expect(page).to have_css('a[data-alchemy-hotkey="alt+i"]')
      end
    end

    context "with icon_style set" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          icon_style: "fill"
        )
      end

      it "passes it to the icon" do
        render_inline component
        expect(page).to have_css('alchemy-icon[icon-style="fill"]')
      end
    end

    context "with tooltip_placement set" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          tooltip_placement: "bottom-center"
        )
      end

      it "passes it to the icon" do
        render_inline component
        expect(page).to have_css('sl-tooltip[placement="bottom-center"]')
      end
    end

    context "with active set to true" do
      let(:component) do
        described_class.new(
          url: admin_dashboard_path,
          icon: "info",
          label: "Show Info",
          active: true
        )
      end

      it "button has active class" do
        render_inline component
        expect(page).to have_css("a.active")
      end
    end
  end

  context "without permission" do
    before { expect(component).to receive(:can?) { false } }

    it "returns empty string" do
      render_inline component
      expect(page.native.inner_html).to be_empty
    end
  end

  context "with disabled permission check" do
    before { expect(component).not_to receive(:can?) { false } }

    let(:component) do
      described_class.new(
        url: admin_dashboard_path,
        icon: "info",
        label: "Show Info",
        skip_permission_check: true
      )
    end

    it "renders a toolbar button" do
      render_inline component
      expect(page).to have_css %(sl-tooltip .icon_button[href="#{admin_dashboard_path}"])
    end
  end

  context "with empty permission option" do
    before { expect(component).to receive(:can?) { true } }

    let(:component) do
      described_class.new(
        url: admin_dashboard_path,
        icon: "info",
        label: "Show Info",
        if_permitted_to: ""
      )
    end

    it "returns reads the permission from url" do
      expect(component).to receive(:permissions_from_url)
      render_inline component
      expect(page).to have_css %(sl-tooltip .icon_button[href="#{admin_dashboard_path}"])
    end
  end
end
