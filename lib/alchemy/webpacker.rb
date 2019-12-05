# frozen_string_literal: true

require 'webpacker'

module Alchemy
  module Webpacker
    # We want to use our custom configuration class
    class Instance < ::Webpacker::Instance
      def config
        @config ||= Configuration.new(
          root_path: root_path,
          config_path: config_path,
          env: env
        )
      end
    end

    # We want to output the packs into the Apps public path
    class Configuration < ::Webpacker::Configuration
      # # Overwritten to use the main apps cache_path
      # def cache_path
      #   ::Webpacker.config.cache_path
      # end

      # Overwritten to use the main apps public_path
      def public_path
        ::Webpacker.config.public_path
      end

      # Overwritten to use the main apps public_output_path
      def public_output_path
        public_path.join('alchemy-packs')
      end
    end
  end

  # Our webpacker instance used by the javascript_pack_tag helper in Alchemy admin layout
  def self.webpacker
    @webpacker ||= Webpacker::Instance.new(
      root_path: Engine.root,
      config_path: Engine.root.join('config/webpacker.yml')
    )
  end
end
