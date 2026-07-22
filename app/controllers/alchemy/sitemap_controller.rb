# frozen_string_literal: true

module Alchemy
  # Renders a search engine compatible XML sitemap.
  #
  # The sitemap contains absolute urls, so it has to follow the site's primary
  # host redirect just like a page request does.
  #
  class SitemapController < Alchemy::BaseController
    include SiteRedirects

    # Still the pages template, because apps override it at that path.
    #
    # TODO: Move to alchemy/sitemap/show in Alchemy 9.0, together with the
    # deprecated PagesController#sitemap.
    TEMPLATE = "alchemy/pages/sitemap"

    def show
      if sitemap_caching_enabled?
        render_cached_sitemap
      else
        render_sitemap
      end
    end

    private

    # Renders the sitemap and stores it in the cache.
    #
    # The etag is checked before the pages are loaded, so a revalidating client
    # only costs us the aggregate cache key queries, not a full render.
    #
    def render_cached_sitemap
      cache_key = sitemap_cache_key
      expires_in sitemap_max_age, public: true

      return unless stale?(etag: cache_key, public: true)

      # The time bucket in the cache key already rotates every max_age seconds.
      # The expiry is only here so that stale buckets do not pile up in cache
      # stores that do not evict on their own.
      xml = Rails.cache.fetch(cache_key, expires_in: sitemap_max_age) do
        render_sitemap_to_string
      end

      render xml: xml
    end

    def render_sitemap
      @pages = Page.sitemap
      render template: TEMPLATE, layout: "alchemy/sitemap"
    end

    def render_sitemap_to_string
      @pages = Page.sitemap
      render_to_string(template: TEMPLATE, layout: "alchemy/sitemap", formats: [:xml])
    end

    def sitemap_cache_key
      Page::SitemapCacheKey.new(
        site: Current.site,
        base_url: request.base_url,
        max_age: sitemap_max_age
      ).call
    end

    def sitemap_max_age
      Alchemy.config.sitemap.max_age
    end

    # The sitemap has its own cache setting and does not follow the page cache.
    # A max_age of zero (or less) disables it, because it would leave the time
    # bucket undefined.
    def sitemap_caching_enabled?
      perform_caching && sitemap_max_age.to_i.positive?
    end
  end
end
