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

Alchemy now uses the Dragonfly middleware to render the pictures.

To maintain compatibility we installed a Dragonfly configuration into your host app,
that provides the default picture caching strategy of Alchemy.

For most installations nothing have changed. The rendered picture still gets stored into `public/pictures`
so the web server can pick up the file and serve it without hitting the Rails process at all.

This may or may not what you want. Especially for multi server setups you eventually want to use
something like S3. This is now possible. Please follow the guidelines about picture caching on the
Dragonfly homepage:

http://markevans.github.io/dragonfly/cache/

NOTE
      todo notice, 'Alchemy v3.5 changes'
    end
  end
end
