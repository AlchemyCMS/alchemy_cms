# frozen_string_literal: true

module Alchemy
  module ConfigurationMethods
    extend ActiveSupport::Concern

    included do
      helper_method :configuration, :multi_language?, :multi_site?, :prefix_locale?
    end

    # Returns the configuration value of given key.
    #
    # Config file is in +config/alchemy/config.yml+
    #
    def configuration(name)
      Config.get(name)
    end

    # Returns true if more than one language is published on current site.
    #
    def multi_language?
      Language.on_current_site.published.count > 1
    end

    # Decides if the locale should be prefixed to urls
    #
    # If the current language's locale (or the optionally passed in locale)
    # matches the current I18n.locale then the prefix os omitted.
    # Also, if only one published language exists.
    #
    def prefix_locale?(locale = Language.current.code)
      multi_language? && locale != ::I18n.default_locale.to_s
    end

    # Returns true if more than one site exists.
    #
    def multi_site?
      Site.count > 1
    end
  end
end
