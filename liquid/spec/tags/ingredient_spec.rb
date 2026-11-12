# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Tags::Ingredient, type: :helper do
  let(:page) { create(:alchemy_page, autogenerate_elements: false) }
  let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page.draft_version) }

  before do
    element.ingredient_by_role(:headline).update!(value: "Hello", level: 2)
    element.ingredient_by_role(:text).update!(value: "<b>Text</b>")
  end

  it "renders the ingredient of the element variable by role" do
    html = render_liquid('{% ingredient "headline" %}', element: element)
    expect(html).to have_css("h2", text: "Hello")
  end

  it "renders a given ingredient drop" do
    html = render_liquid("{% ingredient element.ingredients.text %}", element: element)
    expect(html).to eq("&lt;b&gt;Text&lt;/b&gt;")
  end

  it "renders the ingredient of another element" do
    html = render_liquid('{% ingredient "headline", element: other %}', other: element)
    expect(html).to have_css("h2", text: "Hello")
  end

  it "passes options to the view component" do
    html = render_liquid('{% ingredient "headline", level: 4 %}', element: element)
    expect(html).to have_css("h4", text: "Hello")
  end

  it "renders nothing for unknown roles" do
    expect(render_liquid('{% ingredient "nope" %}', element: element)).to eq("")
  end

  it "raises without an element" do
    expect { render_liquid('{% ingredient "headline" %}') }.to raise_error(ActionView::Template::Error, /needs an element/)
  end

  it "raises a syntax error without arguments" do
    expect { render_liquid("{% ingredient %}") }.to raise_error(ActionView::Template::Error, /needs a role or an ingredient/)
  end

  it "raises a syntax error with invalid arguments" do
    expect { render_liquid('{% ingredient "a" "b" %}') }.to raise_error(ActionView::Template::Error, /Invalid arguments/)
  end
end
