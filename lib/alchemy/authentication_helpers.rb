module Alchemy
  module AuthenticationHelpers

    def self.included(base)
      base.send :alias_method, :current_alchemy_user, :current_user
    end

  end
end
