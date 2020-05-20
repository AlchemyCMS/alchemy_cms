# frozen_string_literal: true

require "uri"

module Alchemy
  module Admin
    # = Preview window URL configuration
    #
    # By default Alchemy uses its internal page preview renderer,
    # but you can configure it to be any URL instead.
    #
    # Basic Auth is supported.
    #
    # == Example config/alchemy/config.yml
    #
    #     preview:
    #       host: https://www.my-static-site.com
    #       auth:
    #         username: <%= ENV["BASIC_AUTH_USERNAME"] %>
    #         password: <%= ENV["BASIC_AUTH_PASSWORD"] %>
    #
    class PreviewUrl
      class MissingProtocolError < StandardError; end

      def initialize(routes:)
        @routes = routes.url_helpers
        @preview_config = Alchemy::Config.get(:preview)
      end

      def url_for(page)
        if preview_config
          uri_class.build(
            host: uri.host,
            path: "/#{page.urlname}",
            userinfo: userinfo,
          ).to_s
        else
          routes.admin_page_path(page)
        end
      end

      private

      attr_reader :preview_config, :routes

      def uri
        URI(preview_config["host"])
      end

      def uri_class
        if uri.class == URI::Generic
          raise MissingProtocolError, "Please provide the protocol with preview['host']"
        else
          uri.class
        end
      end

      def userinfo
        auth = preview_config["auth"]
        auth ? "#{auth["username"]}:#{auth["password"]}" : nil
      end
    end
  end
end
