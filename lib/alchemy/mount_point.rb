module Alchemy

  # Returns alchemys mount point in current rails app.
  # Pass false to not return a leading slash on empty mount point.
  def self.mount_point(remove_leading_slash_if_blank = true)
    alchemy_routes = Rails.application.routes.named_routes[:alchemy]
    raise "Alchemy not mounted! Please mount Alchemy::Engine in your config/routes.rb file." if alchemy_routes.nil?
    mount_point = alchemy_routes.path.spec.to_s
    if remove_leading_slash_if_blank && mount_point == "/"
      mount_point.gsub(/^\/$/, '')
    else
      mount_point
    end
  end

end
