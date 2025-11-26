module Alchemy
  module UpdateChecks
    class AlchemyApp
      def initialize(origin: nil)
        @origin = origin
      end

      # Returns latest Alchemy gem version.
      # @return [Gem::Version]
      def latest_version
        @_latest_version ||= begin
          response = fetch_version
          Gem::Version.new(response["latest_version"])
        end
      end

      private

      attr_reader :origin

      def fetch_version
        response = request_api
        if response.is_a?(Net::HTTPSuccess)
          JSON.parse(response.body)
        else
          raise UpdateServiceUnavailable
        end
      end

      def request_api
        url = URI.parse(uri)
        request = Net::HTTP::Post.new(url.path)
        request["Content-Type"] = content_type
        request["Accept"] = content_type
        request["User-Agent"] = user_agent
        request["Origin"] = origin
        request.body = params.to_json
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = true if url.scheme == "https"
        connection.request(request)
      end

      def uri = "https://app.alchemy-cms.com/update-check"

      def content_type = Marcel::EXTENSIONS["json"]

      def user_agent = "AlchemyCMS/#{current_version} (Rails/#{rails_version}; Ruby/#{ruby_version})"

      def params = {current_version:, rails_version:, ruby_version:}

      def current_version = Alchemy.gem_version.to_s

      def rails_version = Rails.version

      def ruby_version = RUBY_VERSION
    end
  end
end
