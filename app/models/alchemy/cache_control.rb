# frozen_string_literal: true

module Alchemy
  # Normalized HTTP Cache-Control directives derived from a page layout `cache`
  # or element `page_cache` config value. Combine two values with `#&` to get the
  # most restrictive of the two — this is how the page layout and its elements
  # are merged (elements can only tighten, never loosen).
  class CacheControl
    VISIBILITIES = [:public, :private].freeze

    # @param value [nil, true, false, Integer, Hash, CacheControl]
    # @return [CacheControl]
    def self.parse(value)
      case value
      when CacheControl then value
      when nil, true then new(default: true)
      when false then new(no_store: true)
      when Integer then new(max_age: value)
      when Hash then from_hash(value)
      else new(default: true)
      end
    end

    def self.from_hash(hash)
      options = hash.transform_keys(&:to_sym)
      new(
        no_store: !!options[:no_store],
        no_cache: !!options[:no_cache],
        max_age: options[:max_age],
        visibility: (options[:visibility] || :public).to_sym
      )
    end
    private_class_method :from_hash

    attr_reader :max_age, :visibility

    def initialize(no_store: false, no_cache: false, max_age: nil, visibility: :public, default: false)
      @no_store = no_store
      @no_cache = no_cache
      @max_age = max_age
      @visibility = visibility
      @default = default
    end

    def no_store?
      @no_store
    end

    def no_cache?
      @no_cache
    end

    def default?
      @default
    end

    # Whether the response is flagged `public` to HTTP caches. A no-cache
    # response is never public: Rails only pairs no-cache with public, and
    # "public" adds nothing to an always-revalidated response.
    def public?
      visibility == :public && !no_cache?
    end

    def private?
      visibility == :private
    end

    # Most restrictive of self and other.
    def &(other)
      return self if other.nil?
      return self.class.new(no_store: true) if no_store? || other.no_store?

      vis = (private? || other.private?) ? :private : :public
      return self.class.new(no_cache: true, visibility: vis) if no_cache? || other.no_cache?

      self.class.new(visibility: vis, max_age: min_max_age(other))
    end

    def restrict_visibility
      return self if no_store? || private?

      self.class.new(no_cache: no_cache?, max_age: max_age, visibility: :private)
    end

    def ==(other)
      other.is_a?(CacheControl) &&
        no_store? == other.no_store? &&
        no_cache? == other.no_cache? &&
        max_age == other.max_age &&
        visibility == other.visibility
    end
    alias_method :eql?, :==

    def hash
      [no_store?, no_cache?, max_age, visibility].hash
    end

    private

    def min_max_age(other)
      [max_age, other.max_age].compact.min
    end
  end
end
