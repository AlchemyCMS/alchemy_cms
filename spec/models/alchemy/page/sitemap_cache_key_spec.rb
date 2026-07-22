# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Page::SitemapCacheKey do
  let!(:page) { create(:alchemy_page, :public, sitemap: true) }
  let(:site) { page.site }

  let(:max_age) { 3600 }

  # Not a memoized +subject+ on purpose. The whole point of these examples is
  # that a second call returns a different key.
  def cache_key(site: self.site, base_url: "https://example.com")
    described_class.new(
      site: site,
      base_url: base_url,
      max_age: max_age
    ).call
  end

  before { Alchemy::Current.site = site }

  it "returns an array" do
    expect(cache_key).to be_an(Array)
  end

  it "is stable for repeated calls within the same time bucket" do
    expect(cache_key).to eq(cache_key)
  end

  describe "content invalidation" do
    it "changes when a sitemap page is added" do
      before_key = cache_key
      create(:alchemy_page, :public, sitemap: true)
      expect(cache_key).to_not eq(before_key)
    end

    it "changes when a sitemap page is updated" do
      before_key = cache_key
      travel 1.second do
        page.touch
        expect(cache_key).to_not eq(before_key)
      end
    end

    it "changes when a page leaves the sitemap scope" do
      before_key = cache_key
      page.update!(sitemap: false)
      expect(cache_key).to_not eq(before_key)
    end
  end

  describe "time bucketing" do
    # Buckets are aligned to absolute time, so we pin the clock to the start of
    # a bucket. Otherwise an example starting near a boundary would cross it.
    let(:bucket_start) { Time.at((Time.utc(2026, 1, 1).to_i / max_age) * max_age).utc }

    after { travel_back }

    it "does not change before max_age has elapsed" do
      travel_to(bucket_start)
      before_key = cache_key

      travel_to(bucket_start + max_age - 10)
      expect(cache_key).to eq(before_key)
    end

    # Regression test: without a time bucket the ETag would never change,
    # so revalidating clients would receive 304 forever and scheduled pages
    # would never enter the sitemap.
    it "changes once max_age has elapsed" do
      travel_to(bucket_start)
      before_key = cache_key

      travel_to(bucket_start + max_age + 10)
      expect(cache_key).to_not eq(before_key)
    end
  end

  describe "request scoping" do
    it "differs by host" do
      expect(cache_key(base_url: "https://example.com"))
        .to_not eq(cache_key(base_url: "https://www.example.org"))
    end

    it "differs by protocol" do
      expect(cache_key(base_url: "https://example.com"))
        .to_not eq(cache_key(base_url: "http://example.com"))
    end

    it "differs by port" do
      expect(cache_key(base_url: "http://example.com:8080"))
        .to_not eq(cache_key(base_url: "http://example.com:9090"))
    end

    it "differs by site" do
      other_site = create(:alchemy_site, host: "other.com")
      expect(cache_key(site: site)).to_not eq(cache_key(site: other_site))
    end
  end

  context "when no site is present" do
    let(:site) { nil }

    it "still returns a key" do
      expect(cache_key).to be_an(Array)
    end
  end
end
