# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Tags::ElementView, type: :helper do
  let(:page) { create(:alchemy_page, autogenerate_elements: false) }
  let(:element) { create(:alchemy_element, name: "headline", page_version: page.draft_version) }

  it "wraps the content with element_view_for" do
    html = render_liquid("{% element_view %}<p>hi</p>{% endelement_view %}", element: element)
    expect(html).to eq("<div><p>hi</p></div>")
  end

  it "passes tag, class and id" do
    html = render_liquid('{% element_view element, tag: "section", class: "x", id: "y" %}a{% endelement_view %}', element: element)
    expect(html).to eq('<section class="x" id="y">a</section>')
  end

  it "renders no wrapper with tag: false" do
    html = render_liquid("{% element_view tag: false %}a{% endelement_view %}", element: element)
    expect(html).to eq("a")
  end

  it "adds the preview attributes in preview mode" do
    Alchemy::Current.preview_page = page
    html = render_liquid("{% element_view %}{% endelement_view %}", element: element)
    expect(html).to have_css("div[data-alchemy-element='#{element.id}']")
  end

  it "raises without an element" do
    expect { render_liquid("{% element_view %}{% endelement_view %}") }.to raise_error(ActionView::Template::Error, /needs an element/)
  end
end
