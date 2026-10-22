require "alchemy/devise/configuration"
require "alchemy/devise/engine"

module Alchemy
  module Devise
    extend self

    def deprecator
      ActiveSupport::Deprecation.new("9.0", "Alchemy::Devise")
    end

    delegate :layout=, to: :config
    deprecate "layout=": "Use `Alchemy::Devise.config.layout=` instead.",
      deprecator: Alchemy::Devise.deprecator

    delegate :layout, to: :config
    deprecate layout: "Use `Alchemy::Devise.config.layout` instead.",
      deprecator: Alchemy::Devise.deprecator

    def config
      @config ||= Alchemy::Devise::Configuration.new
    end

    def configure(&blk)
      yield config
    end
  end

  extend self

  deprecate devise_modules: "Alchemy::Devise.config.devise_modules", deprecator: Alchemy::Devise.deprecator
  delegate :devise_modules, to: "Alchemy::Devise.config"
end
