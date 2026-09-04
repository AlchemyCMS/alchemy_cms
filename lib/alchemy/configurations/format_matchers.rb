# frozen_string_literal: true

module Alchemy
  module Configurations
    class FormatMatchers < Alchemy::Configuration
      # Naming the hierarchical schemes explicitly matters: a shape match like
      # `[a-z]+://` also admits `javascript://%0aalert(1)`, which browsers
      # execute. This is the link dialog's client side check only, the server
      # side boundary is Alchemy.config.allowed_url_schemes.
      LINK_URL = /^((mailto|tel):|(https?|ftp):\/\/|\/)/

      option :email, :regexp, default: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      option :url, :regexp, default: /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
      option :link_url, :regexp, default: LINK_URL
    end
  end
end
