require 'rails'

module Alchemy
  # Utilities for Alchemy's mount point in the host rails app.
  #
  class MountPoint
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
        all_routes = Rails.application.routes.routes
        alchemy_route = all_routes.find { |r| r.name == Alchemy::Engine.engine_name }
        raise NotMountedError if alchemy_route.nil?
        alchemy_route.path.spec.to_s
      end
    end
  end
end
