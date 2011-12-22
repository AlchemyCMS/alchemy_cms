module Alchemy

	# Returns alchemys mount point in current rails app.
	def self.mount_point
		alchemy_routes = Rails.application.routes.named_routes[:alchemy]
		raise "Alchemy not mounted! Please mount Alchemy::Engine in your config/routes.rb file." if alchemy_routes.nil?
		alchemy_routes.path.gsub(/^\/$/, '')
	end

end