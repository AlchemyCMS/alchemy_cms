require "rails_helper"

RSpec.describe Alchemy::Admin::PictureDescriptionSelect, type: :component do
  let(:component) do
    described_class.new(
      url: "/some/url",
      selected: selected,
      name_prefix: "some_prefix"
    )
  end

  subject(:render) do
    render_inline(component)
  end

  context "when there are multiple languages" do
    let(:selected) { language.id }

    context "when there is only one site" do
      let!(:language) { create(:alchemy_language, :english, site: site) }
      let!(:german) { create(:alchemy_language, :german, site: site) }
      let(:site) { create(:alchemy_site) }

      before do
        allow_any_instance_of(described_class).to receive(:multi_site?).and_return(false)
        render
      end

      it "renders the select box with both languages" do
        expect(page).to have_select("Language", options: ["EN", "DE"], selected: "EN")
        expect(page).to have_selector("select[data-url='/some/url']")
      end
    end
  end

  context "when there is only one published language" do
    let(:selected) { language.id }
    let!(:language) { create(:alchemy_language, :english) }

    before do
      allow_any_instance_of(described_class).to receive(:multi_site?).and_return(false)
      render
    end

    it "does not render the component" do
      expect(rendered_content).to be_empty
    end
  end
end
