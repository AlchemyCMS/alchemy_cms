require "rails_helper"

RSpec.describe Alchemy::Admin::Icon, type: :component do
  before do
    render
  end

  subject(:render) do
    render_inline described_class.new(name)
  end

  let(:name) { "info" }

  it "renders an alchemy-icon with given icon name" do
    expect(page).to have_css 'alchemy-icon[name="information"]'
  end

  context "with style" do
    subject(:render) do
      render_inline described_class.new(name, style: style)
    end

    context "set to fill" do
      let(:style) { "fill" }

      it "renders an alchemy-icon with style set to fill" do
        expect(page).to have_css 'alchemy-icon[name="information"][icon-style="fill"]'
      end
    end

    context "set to solid" do
      let(:style) { "solid" }

      it "renders an alchemy-icon with style set to fill" do
        expect(page).to have_css 'alchemy-icon[name="information"][icon-style="fill"]'
      end
    end

    context "set to regular" do
      let(:style) { "regular" }

      it "renders an alchemy-icon with style set to line" do
        expect(page).to have_css 'alchemy-icon[name="information"][icon-style="line"]'
      end
    end

    context "set to m" do
      let(:style) { "m" }

      it "renders an alchemy-icon with style set to m" do
        expect(page).to have_css 'alchemy-icon[name="information"][icon-style="m"]'
      end
    end

    context "set to false" do
      let(:style) { false }

      it "renders an alchemy-icon with style set to none" do
        expect(page).to have_css 'alchemy-icon[name="information"][icon-style="none"]'
      end
    end
  end

  context "with size set" do
    subject(:render) do
      render_inline described_class.new(name, size: "1x")
    end

    it "renders an alchemy-icon with size set" do
      expect(page).to have_css 'alchemy-icon[name="information"][size="1x"]'
    end
  end

  context "with class option given" do
    subject(:render) do
      render_inline described_class.new(name, class: "disabled")
    end

    it "renders a remix icon with additional css class" do
      expect(page).to have_css "alchemy-icon.disabled"
    end
  end

  describe "#ri_icon" do
    subject { described_class.new(icon_name).send(:ri_icon) }

    context "when `minus`, `remove` or `delete` icon name is given" do
      %w[minus remove delete].each do |type|
        let(:icon_name) { type }

        it { is_expected.to eq "delete-bin-2" }
      end
    end

    context "when `plus` icon name is given" do
      let(:icon_name) { "plus" }

      it { is_expected.to eq "add" }
    end

    context "when `copy` icon name is given" do
      let(:icon_name) { "copy" }

      it { is_expected.to eq "file-copy" }
    end

    context "when `download` icon name is given" do
      let(:icon_name) { "download" }

      it { is_expected.to eq "download-2" }
    end

    context "when `upload` icon name is given" do
      let(:icon_name) { "upload" }

      it { is_expected.to eq "upload-2" }
    end

    context "when `exclamation` icon name is given" do
      let(:icon_name) { "exclamation" }

      it { is_expected.to eq "alert" }
    end

    context "when `info` or `info-circle` icon name is given" do
      %w[info info-circle].each do |type|
        let(:icon_name) { type }

        it { is_expected.to eq "information" }
      end
    end

    context "when `times` icon name is given" do
      let(:icon_name) { "times" }

      it { is_expected.to eq "close" }
    end

    context "when `tag` icon name is given" do
      let(:icon_name) { "tag" }

      it { is_expected.to eq "price-tag-3" }
    end

    context "when `cog` icon name is given" do
      let(:icon_name) { "cog" }

      it { is_expected.to eq "settings-3" }
    end

    context "when unknown icon name is given" do
      let(:icon_name) { "foo" }

      it "returns the given icon name" do
        is_expected.to eq "foo"
      end
    end
  end
end
