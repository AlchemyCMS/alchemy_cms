require "rails_helper"

RSpec.describe Alchemy::Admin::PageSelect, type: :component do
  before do
    render
  end

  context "without parameters" do
    subject(:render) do
      render_inline(described_class.new) { "Page Select Content" }
    end

    it "should render the component and render given block content" do
      expect(page).to have_selector("alchemy-page-select")
      expect(page).to have_text("Page Select Content")
    end

    it "should not allow clearing" do
      expect(page).not_to have_selector("alchemy-page-select[allow-clear]")
    end

    it "should have the default placeholder" do
      expect(page).to have_selector("alchemy-page-select[placeholder='Search page']")
    end

    it "should have the default page api - url" do
      expect(page).to have_selector("alchemy-page-select[url='/api/pages']")
    end

    it "should not have a selection" do
      expect(page).to_not have_selector("alchemy-page-select[selection]")
    end
  end

  context "with page" do
    let(:alchemy_page) { create(:alchemy_page, id: 123, name: "Test Page") }
    subject(:render) do
      render_inline(described_class.new(alchemy_page))
    end

    it "should have a serialized page information" do
      expect(page).to have_selector('alchemy-page-select[selection="{\"id\":123,\"name\":\"Test Page\",\"url_path\":\"/test-page\"}"]')
    end
  end

  context "with url" do
    subject(:render) do
      render_inline(described_class.new(nil, url: "/foo-bar"))
    end

    it "should have an url parameter" do
      expect(page).to have_selector('alchemy-page-select[url="/foo-bar"]')
    end
  end

  context "with allow clear" do
    subject(:render) do
      render_inline(described_class.new(nil, allow_clear: true))
    end

    it "should not have a allow_clear attribute" do
      expect(page).to have_selector("alchemy-page-select[allow-clear]")
    end
  end

  context "with custom placeholder" do
    subject(:render) do
      render_inline(described_class.new(nil, placeholder: "Custom Placeholder"))
    end

    it "should have a custom placeholder" do
      expect(page).to have_selector("alchemy-page-select[placeholder='Custom Placeholder']")
    end
  end

  context "with query parameter" do
    subject(:render) do
      render_inline(described_class.new(nil, query_params: {foo: :bar}))
    end

    it "should have serialized custom parameter" do
      expect(page).to have_selector('alchemy-page-select[query-params="{\"foo\":\"bar\"}"]')
    end
  end
end
