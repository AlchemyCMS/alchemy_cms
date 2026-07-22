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
        expires_in sitemap_max_age, public: true

        # The etag is checked before the pages are loaded, so a revalidating
        # client only costs us the cache key queries, not a full render.
        return unless stale?(etag: sitemap_cache_key, public: true)

        @sitemap_cache_key = sitemap_cache_key
        @sitemap_max_age = sitemap_max_age
      end

      # Left unloaded on purpose. The template wraps the urls in a fragment
      # cache, so a cache hit never runs this query.
      @pages = Page.sitemap

      render template: TEMPLATE, layout: "alchemy/sitemap"
    end

    private

    def sitemap_cache_key
      @_sitemap_cache_key ||= Page::SitemapCacheKey.new(
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
