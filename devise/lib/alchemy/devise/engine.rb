require 'alchemy_cms'
require 'devise'

module Alchemy
  module Devise
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy
      engine_name 'alchemy'
      config.mount_at = '/'

      config.to_prepare do
        require_relative '../../../controllers/alchemy/base_controller.rb'
      end
    end
  end
end
