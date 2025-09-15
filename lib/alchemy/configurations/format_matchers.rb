# frozen_string_literal: true

module Alchemy
  module Configurations
    class FormatMatchers < Alchemy::Configuration
      option :email, :regexp, default: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      option :url, :regexp, default: /\A[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
      option :link_url, :regexp, default: /^(tel:|mailto:|\/|[a-z]+:\/\/)/
    end
  end
end
