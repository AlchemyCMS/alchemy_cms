# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Handler, type: :helper do
  before { described_class.clear_cache! }

  it "is registered for .liquid templates" do
    expect(ActionView::Template.registered_template_handler(:liquid)).to eq(described_class)
  end

  it "renders a template with locals" do
    expect(render_liquid("Hello {{ name }}", name: "World")).to eq("Hello World")
  end

  it "returns html safe output" do
    expect(render_liquid("<b>hi</b>")).to be_html_safe
  end

  it "wraps Alchemy records passed as locals into drops" do
    page = build_stubbed(:alchemy_page, name: "Home")
    expect(render_liquid("{{ page.name }}", page: page)).to eq("Home")
  end

  it "does not expose records that have no drop" do
    picture = build_stubbed(:alchemy_picture)
    expect(render_liquid("[{{ picture }}]", picture: picture)).to eq("[]")
  end

  it "parses each source only once" do
    expect(Liquid::Template).to receive(:parse).once.and_call_original
    2.times { described_class.render("abc", "{{ x }}", helper, {x: 1}) }
  end

  it "parses in strict error mode" do
    expect { render_liquid("{{ foo | | bar }}") }.to raise_error(ActionView::Template::Error) do |error|
      expect(error.cause).to be_a(Liquid::SyntaxError)
    end
  end

  it "raises on unknown filters" do
    expect { render_liquid("{{ 'a' | nope }}") }.to raise_error(ActionView::Template::Error) do |error|
      expect(error.cause).to be_a(Liquid::UndefinedFilter)
    end
  end

  it "puts the view context into the :view register" do
    view = nil
    allow_any_instance_of(Liquid::Template).to receive(:render!).and_wrap_original do |original, assigns, options|
      view = options[:registers][:view]
      original.call(assigns, options)
    end
    described_class.render("def", "x", helper, {})
    expect(view).to eq(helper)
  end

  describe ".clear_cache!" do
    it "empties the parse cache" do
      described_class.render("ghi", "x", helper, {})
      expect { described_class.clear_cache! }.to change { described_class.cache.size }.from(1).to(0)
    end
  end
end
