# frozen_string_literal: true

module Alchemy
  module Configurations
    class FormatMatchers < Alchemy::Configuration
      option :email, :regexp, default: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      option :url, :regexp, default: /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
      option :link_url, :regexp, default: /^(tel:|mailto:|\/|[a-z]+:\/\/)/
      option :integer, :regexp, default: /\A\d+\z/
      option :uuid, :regexp, default: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    end
  end
end
