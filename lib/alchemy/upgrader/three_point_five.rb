require_relative 'tasks/install_dragonfly_config'

module Alchemy
  module Upgrader::ThreePointFive
    private

    def install_dragonfly_config
      desc 'Install dragonfly config into `config/initializers`'
      Alchemy::Upgrader::Tasks::InstallDragonflyConfig.new.install
    end

    def alchemy_3_5_todos
      notice = <<-NOTE

Picture rendering switched to Dragonfly middleware
--------------------------------------------------

Alchemy now uses the Dragonfly middleware to render the pictures and
REMOVED THE LOCAL PICTURE CACHING!

This has effect on your production setup and NEEDS FURTHER ACTION in order to
provide a caching option that works for your setup.

Please follow the guidelines about picture caching on the Dragonfly homepage:

http://markevans.github.io/dragonfly/cache/

NOTE
      todo notice, 'Alchemy v3.5 changes'
    end
  end
end
