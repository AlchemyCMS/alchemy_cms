require "alchemy_cms"
require "devise"
require "flickwerk"

module Alchemy
  module Devise
    class Engine < ::Rails::Engine
      include Flickwerk

      isolate_namespace Alchemy
      engine_name "alchemy_devise"

      initializer "alchemy_devise.user_class", before: "alchemy.userstamp" do
        Alchemy.user_class_name = "Alchemy::User"
      end

      initializer "alchemy_devise.assets" do |app|
        app.config.assets.precompile += [
          "alchemy-devise.css"
        ]
      end
    end
  end
end
