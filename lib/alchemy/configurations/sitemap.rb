# frozen_string_literal: true

module Alchemy
  module Configurations
    class Sitemap < Alchemy::Configuration
      option :show_root, :boolean, default: true
      option :show_flag, :boolean, default: false
    end
  end
end
