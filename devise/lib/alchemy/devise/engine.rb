require "alchemy_cms"
require "devise"
require "flickwerk"
require_relative "../../../app/helpers/alchemy/devise/user_impersonation_helper"

module Alchemy
  module Devise
    class Engine < ::Rails::Engine
      include Flickwerk

      isolate_namespace Alchemy
      engine_name "alchemy_devise"

      initializer "alchemy_devise.user_class", before: "alchemy.userstamp" do
        Alchemy.config.user_class = "Alchemy::User"
      end

      initializer "alchemy_devise.assets" do |app|
        app.config.assets.precompile += [
          "alchemy-devise.css"
        ]
      end

      initializer "alchemy_devise.user_impersonation_helper" do
        ActiveSupport.on_load(:action_controller_base) do
          helper Alchemy::Devise::UserImpersonationHelper
        end
      end
    end
  end
end
