require 'rails'

module Alchemy

  # Utilities for Alchemy's mount point in the host rails app.
  #
  class MountPoint
    MOUNT_POINT_REGEXP = /mount\sAlchemy::Engine\s=>\s['|"](\/\w*)['|"]/

    class << self

      # Returns the path of Alchemy's mount point in current rails app.
      #
      # @param [Boolean] remove_leading_slash_if_blank
      #   Pass false to not return a leading slash on empty mount point.
      #
      def get(remove_leading_slash_if_blank = true)
        if path == "/" && remove_leading_slash_if_blank
          path.gsub(/\A\/\z/, '')
        else
          path
        end
      end

      # Returns the mount point path from the Rails app routes.
      #
      def path
        match = File.read(routes_file_path).match(MOUNT_POINT_REGEXP)
        if match.nil?
          raise "Alchemy mount point not found! Please run `bin/rake alchemy:mount'"
        else
          match[1]
        end
      end

      private

      def routes_file_path
        if Rails.root
          Rails.root.join('config/routes.rb')
        else
          'config/routes.rb'
        end
      end
    end
  end
end
