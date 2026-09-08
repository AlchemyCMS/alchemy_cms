# frozen_string_literal: true

module Alchemy
  module Admin
    # The Content Security Policy Alchemy applies to its own admin responses.
    #
    # Configured by default. Set it to nil to send no policy at all:
    #
    #     Alchemy.config.admin_content_security_policy = nil
    #
    # 'self' follows the origin the admin is served from, so mounting it under
    # its own subdomain through +Alchemy.admin_constraints+ needs no extra
    # configuration. The page preview is same origin as well, because it falls
    # back to an admin path, unless a preview host is configured, in which case
    # that host is added to +frame-src+.
    #
    # Assets your application adds through +admin_stylesheets+ or through
    # +Alchemy.importmap+ are picked up automatically, so a module pinned to a
    # CDN does not need any extra configuration. Subclass to allow anything
    # else, and configure the subclass instead:
    #
    #     class AdminContentSecurityPolicy < Alchemy::Admin::ContentSecurityPolicy
    #       def call
    #         super.tap do |policy|
    #           policy.connect_src(*policy.directives["connect-src"], "https://api.example.com")
    #         end
    #       end
    #     end
    #
    class ContentSecurityPolicy
      class InvalidSourceError < StandardError; end

      # Rails calls an asset host proc with the asset source, so we need one to
      # evaluate it with. Any source resolves to the same origin unless the
      # host shards, which the %d form covers separately.
      ASSET_SOURCE = "/"

      def initialize(request = nil)
        @request = request
      end

      attr_reader :request
      # Send the policy as Content-Security-Policy-Report-Only, which reports
      # violations to the browser console and to +report_uri+ without blocking
      # anything. Worth running first, to find what a policy would break.
      def report_only? = false

      # Authorizes the inline scripts Alchemy renders. It has to be
      # unguessable, otherwise injected markup could carry a valid nonce.
      def nonce_generator = ->(_request) { SecureRandom.base64(16) }

      def call
        ActionDispatch::ContentSecurityPolicy.new do |policy|
          policy.default_src :self
          # script-src and style-src have to be named explicitly, because Rails
          # only appends the nonce to directives the policy actually declares.
          policy.script_src :self, *asset_hosts, *importmap_origins
          policy.style_src :self, *asset_hosts, *admin_stylesheet_origins
          # Inline style attributes cannot carry a nonce. Turbo sets them for
          # its progress bar, and so do several of our bundled dependencies.
          policy.style_src_attr :unsafe_inline
          policy.img_src :self, :data, :blob, *asset_hosts
          policy.font_src :self, :data, *asset_hosts
          policy.media_src :self, :blob, *asset_hosts
          policy.connect_src :self, *asset_hosts
          policy.frame_src :self, *preview_hosts
          policy.object_src :none
          policy.base_uri :self
          policy.form_action :self
          # An endpoint of your own that the browser POSTs a JSON report to
          # whenever it blocks something:
          #
          #   policy.report_uri "/csp-violation-reports"
        end
      end

      private

      def asset_hosts
        host = ActionController::Base.asset_host
        return [] if host.blank?

        hosts = if host.respond_to?(:call)
          [call_asset_host(host)]
        elsif host.include?("%d")
          # Rails shards these over four hosts.
          4.times.map { host % _1 }
        else
          [host]
        end
        hosts.filter_map { origin(_1) }.uniq
      end

      def call_asset_host(host)
        arity = host.respond_to?(:arity) ? host.arity : host.method(:call).arity
        args = [ASSET_SOURCE]
        args << request if request && (arity > 1 || arity < 0)
        host.call(*args)
      end

      # Modules can be pinned to a CDN, in which case the pin holds an absolute
      # URL instead of an asset name.
      def importmap_origins
        Alchemy.importmap.packages.values.filter_map { origin(_1.path) }.uniq
      end

      # Admin stylesheets are usually asset names, but an absolute URL is
      # allowed here too.
      def admin_stylesheet_origins
        Alchemy.config.admin_stylesheets.filter_map { origin(_1) }.uniq
      end

      # A CSP source is an origin, so anything with a host contributes one and
      # everything else (asset names, module specifiers) is same origin already.
      def origin(url)
        uri = URI.parse(url.to_s)
        return nil unless uri.host

        port = ":#{uri.port}" if uri.port && uri.port != uri.default_port
        "#{uri.scheme ? "#{uri.scheme}://" : "//"}#{uri.host}#{port}"
      rescue URI::InvalidURIError => error
        raise InvalidSourceError, "Cannot build a Content Security Policy source from " \
          "#{url.inspect} (#{error.message}). It came from your asset host, your " \
          "admin stylesheets, an importmap pin or a preview host."
      end

      # The page editor renders the frontend of the application in an iframe,
      # which is a different host whenever a preview host is configured.
      def preview_hosts
        preview = Alchemy.config.preview
        ([preview.host] + preview.per_site_configs.map(&:host)).filter_map { origin(_1) }.uniq
      end
    end
  end
end
