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
    end
  end
end
