# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Tags::Elements, type: :helper do
  let(:page) { create(:alchemy_page, :public, page_layout: "everything", autogenerate_elements: false) }

  before do
    Alchemy::Current.page = page
    helper.instance_variable_set(:@page, page)
  end

  context "without a collection" do
    let!(:article) { create(:alchemy_element, name: "article", page_version: page.public_version) }
    let!(:text) { create(:alchemy_element, name: "text", page_version: page.public_version) }

    it "renders the page's elements with render_elements" do
      expect(helper).to receive(:render_elements).with({}).and_call_original
      render_liquid("{% elements %}")
    end

    it "passes only as array" do
      expect(helper).to receive(:render_elements).with({only: ["article", "text"]}).and_return("")
      render_liquid('{% elements only: "article, text" %}')
    end

    it "passes except from a variable" do
      expect(helper).to receive(:render_elements).with({except: ["article"]}).and_return("")
      render_liquid("{% elements except: names %}", names: ["article"])
    end
  end

  context "with a collection" do
    let(:slider) do
      create(:alchemy_element, name: "slider", page_version: page.public_version, autogenerate_nested_elements: false)
    end
    let!(:slides) do
      create_list(:alchemy_element, 2, name: "slide", parent_element: slider, page_version: page.public_version)
    end

    it "renders the given elements" do
      html = render_liquid("{% elements element.nested_elements %}", element: slider)
      expect(html).to have_css("li.liquid-slide", count: 2)
      expect(html).to have_css("li.liquid-slide[data-id='#{slides.first.id}']")
    end

    it "filters the collection with except" do
      html = render_liquid('{% elements element.nested_elements, except: "slide" %}', element: slider)
      expect(html).not_to have_css("li")
    end

    it "is used for nested elements in element partials" do
      html = helper.render_element(slider)
      expect(html).to have_css("ul.liquid-slider li.liquid-slide", count: 2)
    end
  end
end
