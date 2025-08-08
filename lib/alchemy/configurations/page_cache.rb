# frozen_string_literal: true

module Alchemy
  module Configurations
    class PageCache < Alchemy::Configuration
      # === Page caching max age
      #
      # Control the max-age duration in seconds in the cache-control header.
      #
      option :max_age, :integer, default: 600
    end
  end
end
