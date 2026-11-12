# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Tags::Cache, type: :helper do
  let(:store) { ActiveSupport::Cache::MemoryStore.new }

  def render_cached(key, value)
    helper.render(partial: "liquid_spec/cached", locals: {key: key, value: value})
  end

  context "with caching enabled" do
    before do
      allow(helper.controller).to receive(:perform_caching).and_return(true)
      allow(helper.controller).to receive(:cache_store).and_return(store)
    end

    it "caches the block content" do
      expect(render_cached("k", "one")).to eq("<span>one</span>\n")
      expect(render_cached("k", "two")).to eq("<span>one</span>\n")
      expect(render_cached("other", "two")).to eq("<span>two</span>\n")
    end

    it "includes the template digest in the cache key" do
      render_cached("k", "one")
      digest = ActionView::Digestor.digest(name: "liquid_spec/_cached", format: :html, finder: helper.lookup_context)
      expect(store.instance_variable_get(:@data).keys).to include(a_string_including("liquid_spec/_cached:#{digest}/k"))
    end

    it "uses the cache key of a record wrapped in a drop" do
      element = create(:alchemy_element)
      helper.render(partial: "liquid_spec/cached", locals: {key: element, value: "x"})
      expect(store.instance_variable_get(:@data).keys).to include(a_string_including(element.cache_key))
    end
  end

  context "with caching disabled" do
    it "renders the block content" do
      expect(render_cached("k", "one")).to eq("<span>one</span>\n")
      expect(render_cached("k", "two")).to eq("<span>two</span>\n")
    end
  end

  it "raises a syntax error without key" do
    expect { render_liquid("{% cache %}x{% endcache %}") }.to raise_error(ActionView::Template::Error, /needs a cache key/)
  end
end
