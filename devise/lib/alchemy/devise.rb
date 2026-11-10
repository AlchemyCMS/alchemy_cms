require "alchemy/devise/configuration"
require "alchemy/devise/engine"

module Alchemy
  module Devise
    extend self

    def config
      @config ||= Alchemy::Devise::Configuration.new
    end

    def configure(&blk)
      yield config
    end
  end
end
