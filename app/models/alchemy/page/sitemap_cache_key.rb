# frozen_string_literal: true

module Alchemy
  # Builds the cache key for the XML sitemap.
  #
  # The key combines three independent sources of change:
  #
  # 1. The contents of the +Alchemy::Page.sitemap+ scope, as page count and
  #    latest +updated_at+.
  # 2. The requested base url (protocol, host and port), because
  #    +show_alchemy_page_url+ builds absolute urls from +request.base_url+ and
  #    a site can be served under several of them (see +Alchemy::Site.find_for_host+).
  # 3. A coarse time bucket of +max_age+ seconds.
  #
  # The time bucket is what makes scheduled publishing work. Pages enter and
  # leave the sitemap when +public_on+ / +public_until+ pass, without any record
  # being touched, so no content based key can notice that transition. Rotating
  # the key every +max_age+ seconds bounds how long such a page can be missing.
  # It also keeps the ETag from freezing: without it, a revalidating client
  # would receive +304 Not Modified+ forever.
  class Page::SitemapCacheKey
    attr_reader :site, :base_url, :max_age

    # @param site [Alchemy::Site] The site the sitemap is rendered for.
    # @param base_url [String] The requested base url (e.g. +request.base_url+).
    # @param max_age [Integer] Length of the time bucket in seconds.
    def initialize(site:, base_url:, max_age: Alchemy.config.sitemap.max_age)
      @site = site
      @base_url = base_url
      @max_age = max_age
    end

    # @return [Array<Object>]
    def call
      [site&.id, base_url, content_version, time_bucket]
    end

    private

    # Page count and latest +updated_at+ of the sitemap scope.
    #
    # We can not use +ActiveRecord::Relation#cache_key_with_version+ here. The
    # +published+ scope inlines +Time.current+ into its SQL, so the query digest
    # that +cache_key+ is built from would differ on every single call and the
    # key would never be stable.
    def content_version
      pages = Page.sitemap
      timestamp = pages.maximum(Page.arel_table[:updated_at])
      "#{pages.count}-#{timestamp&.to_fs(:usec)}"
    end

    def time_bucket
      Time.current.to_i / max_age
    end
  end
end
