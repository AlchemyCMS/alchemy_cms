require 'alchemy_cms'
require 'devise'

module Alchemy
  module Devise
    class Engine < ::Rails::Engine
      isolate_namespace Alchemy
      engine_name 'alchemy'
      config.mount_at = '/'
    end
  end
end
