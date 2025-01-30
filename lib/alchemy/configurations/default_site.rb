# frozen_string_literal: true

module Alchemy
  module Configurations
    class DefaultSite < Alchemy::Configuration
      option :name, :string, default: "Default Site"
      option :host, :string, default: "*"
    end
  end
end
