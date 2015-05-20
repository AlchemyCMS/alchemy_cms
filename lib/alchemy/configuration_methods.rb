module Alchemy
  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      helper_method :configuration, :multi_language?, :multi_site?
    end

    # Returns the configuration value of given key.
    #
    # Config file is in +config/alchemy/config.yml+
    #
    def configuration(name)
      Config.get(name)
    end

    # Returns true if more than one language is published.
    #
    def multi_language?
      Language.published.count > 1
    end

    # Returns true if more than one site exists.
    #
    def multi_site?
      Site.count > 1
    end
  end
end
