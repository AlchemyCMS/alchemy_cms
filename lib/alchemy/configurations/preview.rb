# frozen_string_literal: true

module Alchemy
  module Configurations
    class Preview < Alchemy::Configuration
      class PreviewAuth < Alchemy::Configuration
        option :username, :string
        option :password, :string
      end

      attr_reader :per_site_configs

      def initialize(configuration = {})
        @per_site_configs = []
        configuration = configuration.with_indifferent_access
        configuration.except(:host, :site_name, :auth).keys.each do |site_name|
          @per_site_configs << Preview.new(configuration[site_name].merge(site_name: site_name))
        end
        super(configuration.slice(:host, :site_name, :auth))
      end

      option :site_name, :string, default: "*"
      option :host, :string

      configuration :auth, PreviewAuth

      def for_site(site)
        per_site_configs.detect { _1.site_name == site.name } || self
      end
    end
  end
end
