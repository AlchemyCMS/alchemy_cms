module Alchemy::Upgrader::Tasks
  class InstallDragonflyConfig < Thor
    include Thor::Actions

    source_root File.expand_path('../../../rails/generators/alchemy/install/templates',
      File.dirname(__FILE__))

    no_tasks do
      def install
        template "dragonfly.rb.tt", "config/initializers/dragonfly.rb"
      end
    end
  end
end
