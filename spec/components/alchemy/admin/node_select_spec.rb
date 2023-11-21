require "rails_helper"

RSpec.describe Alchemy::Admin::NodeSelect, type: :component do
  before do
    render
  end

  context "without parameters" do
    subject(:render) do
      render_inline(described_class.new) { "Node Select Content" }
    end

    it "should render the component and render given block content" do
      expect(page).to have_selector("alchemy-node-select")
      expect(page).to have_text("Node Select Content")
    end

    it "should have the default placeholder" do
      expect(page).to have_selector("alchemy-node-select[placeholder='Search node']")
    end

    it "should have the default node api - url" do
      expect(page).to have_selector("alchemy-node-select[url='/api/nodes']")
    end

    it "should not have a selection" do
      expect(page).to_not have_selector("alchemy-node-select[selection]")
    end
  end

  context "with page" do
    let(:node) { create(:alchemy_node, id: 123, name: "Test Node") }

    subject(:render) do
      render_inline(described_class.new(node))
    end

    it "should have a serialized page information" do
      expect(page).to have_selector('alchemy-node-select[selection="{\"id\":123,\"name\":\"Test Node\",\"lft\":1,\"rgt\":2,\"url\":null,\"parent_id\":null,\"ancestors\":[]}"]')
    end
  end

  context "with url" do
    subject(:render) do
      render_inline(described_class.new(nil, url: "/foo-bar"))
    end

    it "should have an url parameter" do
      expect(page).to have_selector('alchemy-node-select[url="/foo-bar"]')
    end
  end

  context "with custom placeholder" do
    subject(:render) do
      render_inline(described_class.new(nil, placeholder: "Custom Placeholder"))
    end

    it "should have a custom placeholder" do
      expect(page).to have_selector("alchemy-node-select[placeholder='Custom Placeholder']")
    end
  end

  context "with query parameter" do
    subject(:render) do
      render_inline(described_class.new(nil, query_params: {foo: :bar}))
    end

    it "should have serialized custom parameter" do
      expect(page).to have_selector('alchemy-node-select[query-params="{\"foo\":\"bar\"}"]')
    end
  end
end
