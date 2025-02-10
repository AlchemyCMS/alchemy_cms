# frozen_string_literal: true

module Alchemy
  module ConfigMissing
    def const_missing(missing_const_name)
      if missing_const_name == :Config
        Alchemy::Deprecation.warn("Alchemy::Config is deprecated. Use Alchemy.config instead.")
        Alchemy.config
      else
        super
      end
    end
  end
end
