module Alchemy
  module UpdateChecks
    class RubyGems
      def initialize(origin: nil)
      end

      # Returns latest Alchemy gem version.
      # @return [Gem::Version]
      def latest_version
        @_latest_version ||= begin
          versions = fetch_versions
          versions.reject! { _1.prerelease? }
          versions.max
        end
      end

      private

      def fetch_versions
        response = request_api
        if response.is_a?(Net::HTTPSuccess)
          alchemy_versions = JSON.parse(response.body)
          alchemy_versions.map! { Gem::Version.new(_1["number"]) }
        else
          raise UpdateServiceUnavailable
        end
      end

      def request_api
        url = URI.parse("https://rubygems.org/api/v1/versions/alchemy_cms.json")
        request = Net::HTTP::Get.new(url.path)
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = url.scheme == "https"
        connection.request(request)
      end
    end
  end
end
