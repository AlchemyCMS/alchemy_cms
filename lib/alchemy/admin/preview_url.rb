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
    # Preview config per site is supported as well.
    #
    # == Example config/alchemy/config.yml
    #
    #     preview:
    #       My site name:
    #         host: https://www.my-static-site.com
    #         auth:
    #           username: <%= ENV["BASIC_AUTH_USERNAME"] %>
    #           password: <%= ENV["BASIC_AUTH_PASSWORD"] %>
    #
    class PreviewUrl
      extend ActiveModel::Translation

      class MissingProtocolError < StandardError; end

      def initialize(routes:)
        @routes = routes.url_helpers
      end

      def url_for(page)
        @preview_config = preview_config_for(page)
        if @preview_config && uri
          uri_class.build(
            host: uri.host,
            port: uri.port,
            path: page.url_path,
            userinfo: userinfo,
            query: preview_params.to_param
          ).to_s
        else
          path = routes.admin_page_path(page)
          if Current.page_preview_at
            "#{path}?#{preview_at_param}"
          else
            path
          end
        end
      end

      private

      attr_reader :routes

      def preview_params
        params = {alchemy_preview_mode: true}
        params[:alchemy_preview_at] = Current.page_preview_at.iso8601 if Current.page_preview_at
        params
      end

      def preview_at_param
        {alchemy_preview_at: Current.page_preview_at.iso8601}.to_param
      end

      def preview_config_for(page)
        preview_config = Alchemy.config.preview
        return unless preview_config

        preview_config.for_site(page.site) || preview_config
      end

      def uri
        return unless @preview_config["host"]

        URI(@preview_config["host"])
      end

      def uri_class
        if uri.instance_of?(URI::Generic)
          raise MissingProtocolError, "Please provide the protocol with preview['host']"
        else
          uri.class
        end
      end

      def userinfo
        auth = @preview_config.auth
        auth.username ? "#{auth["username"]}:#{auth["password"]}" : nil
      end
    end
  end
end
