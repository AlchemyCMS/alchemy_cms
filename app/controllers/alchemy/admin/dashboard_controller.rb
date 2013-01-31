module Alchemy
  module Admin
    class DashboardController < Alchemy::Admin::BaseController

      def index
        @last_edited_pages = Page.all_last_edited_from(current_user)
        @locked_pages = Page.from_current_site.all_locked
        @online_users = User.logged_in.to_a - [current_user]
        @first_time = current_user.sign_in_count == 1 && current_user.last_sign_in_at.nil?
        @sites = Site.scoped
      end

      def info
        @alchemy_version = Alchemy.version
        render :layout => false
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

      def alchemy_tags
        url = URI.parse('https://api.github.com/repos/magiclabs/alchemy_cms/tags')
        request = Net::HTTP::Get.new(url.path)
        connection = Net::HTTP.new(url.host, url.port)
        connection.use_ssl = true
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = connection.request(request)
        if response.code == "200"
          JSON.parse(response.body)
        else
          raise UpdateServiceUnavailable
        end
      end

      def alchemy_versions
        return [] if alchemy_tags.blank?
        alchemy_tags.collect { |h| h['name'] }.sort
      end

      def latest_alchemy_version
        return '' if alchemy_versions.blank?
        alchemy_versions.last.gsub(/^v/, '')
      end

    end
  end
end
