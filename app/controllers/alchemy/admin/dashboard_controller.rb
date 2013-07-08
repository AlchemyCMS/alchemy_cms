require 'net/http'

module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController

      def index
        @last_edited_pages = Page.from_current_site.all_last_edited_from(current_user)
        @locked_pages = Page.from_current_site.all_locked
        @online_users = User.logged_in.to_a - [current_user]
        @first_time = current_user.sign_in_count == 1 && current_user.last_sign_in_at.nil?
        @sites = Site.all
      end

      def info
        @alchemy_version = Alchemy.version
        render layout: !request.xhr?
      end

      def update_check
        @alchemy_version = Alchemy.version
        if @alchemy_version < latest_alchemy_version
          render :text => 'true'
        else
          render :text => 'false'
        end
      rescue UpdateServiceUnavailable => e
        render :text => e, :status => 503
      end

    private

      # Returns latest alchemy version.
      def latest_alchemy_version
        versions = get_alchemy_versions
        return '' if versions.blank?
        # reject any non release version
        versions.reject! { |v| v =~ /[a-z]/ }
        versions.sort.last
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

      # Query the RubyGems API for alchemy versions.
      def query_rubygems
        make_api_request('https://rubygems.org/api/v1/versions/alchemy_cms.json')
      end

      # Query the GitHub API for alchemy tags.
      def query_github
        make_api_request('https://api.github.com/repos/magiclabs/alchemy_cms/tags')
      end

      # Make a HTTP API request for given request url.
      def make_api_request(request_url)
        url = URI.parse(request_url)
        request = Net::HTTP::Get.new(url.path)
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = true
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        connection.request(request)
      end

    end
  end
end
