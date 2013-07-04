module Alchemy
  # Utitlities for Alchemy's mount point in the host rails app.
  #
  class MountPoint

    # Returns the path of Alchemy's mount point in current rails app.
    #
    # @param [Boolean] remove_leading_slash_if_blank
    #   Pass false to not return a leading slash on empty mount point.
    #
    def self.get(remove_leading_slash_if_blank = true)
      if self.mount_point == "/" && remove_leading_slash_if_blank
        self.mount_point.gsub(/\A\/\z/, '')
      else
        self.mount_point
      end
    end

    # Returns the routes object from Alchemy in the host app.
    #
    def self.routes
      ::Rails.application.routes.named_routes[:alchemy]
    end

    # Returns the raw mount point path from the Rails app routes.
    #
    # If Alchemy is not mounted in the main app, it falls back to root path.
    #
    def self.mount_point
      if self.routes.nil?
        ::Rails.logger.warn <<-WARN
Alchemy is not mounted! Falling back to root path (/).
If you want to change Alchemy's mount point, please mount Alchemy::Engine in your config/routes.rb file.
WARN
        return '/'
      end
      routes.path.spec.to_s
    end

  end
end
