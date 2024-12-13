module Alchemy
  class Upgrader
    module EightZero
      def mention_alchemy_config_initializer
        todo <<~TEXT, "Configuration has changed to initializer"
          Check the new configuration file `./config/initializers/alchemy.rb` and
          update values from your `config/alchemy/config.yml` file.

          Then you can safely remove the `config/alchemy/config.yml` file.
        TEXT
      end

      def install_active_storage
        Rake::Task["active_storage:install"].invoke
        Rake::Task["db:migrate"].invoke
      end

      def set_dragonfly_storage_adapter
        task.prepend_to_file "config/initializers/alchemy.rb", <<~RUBY
          config.storage_adapter = :dragonfly
        RUBY
      end
    end
  end
end
