# frozen_string_literal: true

require 'net/http'
require 'alchemy/version'

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController
      authorize_resource class: :alchemy_admin_dashboard

      def index
        @last_edited_pages = Page.all_last_edited_from(current_alchemy_user)
        @all_locked_pages = Page.locked
        if Alchemy.user_class.respond_to?(:logged_in)
          @online_users = Alchemy.user_class.logged_in.to_a - [current_alchemy_user]
        end
        if current_alchemy_user.respond_to?(:sign_in_count) && current_alchemy_user.respond_to?(:last_sign_in_at)
          @last_sign_at = current_alchemy_user.last_sign_in_at
          @first_time = current_alchemy_user.sign_in_count == 1 && @last_sign_at.nil?
        end
        @sites = Site.all
      end

      def info
        @alchemy_version = Alchemy.version
      end

      def update_check
        @alchemy_version = Alchemy.version
        if @alchemy_version < latest_alchemy_version
          render plain: 'true'
        else
          render plain: 'false'
        end
      rescue UpdateServiceUnavailable => e
        render plain: e, status: 503
      end

      private

      # Returns latest alchemy version.
      def latest_alchemy_version
        versions = get_alchemy_versions
        return '' if versions.blank?
        # reject any non release version
        versions.reject! { |v| v =~ /[a-z]/ }
        versions.max
      end

      # Get alchemy versions from rubygems or github, if rubygems failes.
      def get_alchemy_versions
        # first we try rubygems.org
        response = query_rubygems
        if response.code == "200"
          alchemy_versions = JSON.parse(response.body)
          alchemy_versions.collect { |h| h['number'] }.sort
        else
          # rubygems.org not available?
          # then we try github
          response = query_github
          if response.code == "200"
            alchemy_tags = JSON.parse(response.body)
            alchemy_tags.collect { |h| h['name'] }.sort
          else
            # no luck at all?
            raise UpdateServiceUnavailable
          end
        end
      end

      # Query the RubyGems API for Alchemy versions.
      def query_rubygems
        make_api_request('https://rubygems.org/api/v1/versions/alchemy_cms.json')
      end

      # Query the GitHub API for Alchemy tags.
      def query_github
        make_api_request('https://api.github.com/repos/AlchemyCMS/alchemy_cms/tags')
      end

      # Make a HTTP API request for given request url.
      def make_api_request(request_url)
        url = URI.parse(request_url)
        request = Net::HTTP::Get.new(url.path)
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = true
        connection.request(request)
      end
    end
  end
end
